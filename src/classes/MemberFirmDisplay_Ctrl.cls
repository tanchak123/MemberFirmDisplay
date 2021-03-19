////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// TestClass: Test_Class_Name.cls
// - Written by JOW 2020.01 -
// Description
// 
////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
/* >>- Changelog -<<
* date - author - description
*/
public without sharing class MemberFirmDisplay_Ctrl {

	@AuraEnabled
	public static MemberFirmWrapper getMemberFirmDetails(Id memberFirmId){
		MemberFirmWrapper mfw = new MemberFirmWrapper();

		Profile membeFirmAdmin = [SELECT Id FROM Profile WHERE Name='Member Firm Admin User'];
		User runningUser = [SELECT Id, AccountId FROM User WHERE Id = :UserInfo.getUserId()];

		Id usrProfileId = UserInfo.getProfileId();
		if(usrProfileId==membeFirmAdmin.Id && runningUser.AccountId==memberFirmId){
			mfw.userCanEditMemberFirm=true;
		}

		mfw.contactPicklistValues = new List<PicklistValue>();
		for(Contact con : [SELECT Id, Name FROM Contact WHERE AccountId=:memberFirmId]) {
			PicklistValue plv = new PicklistValue();
			plv.value = con.Id;
			plv.label = con.Name;
			mfw.contactPicklistValues.add(plv);
		}
		mfw.primaryOfficePicklistValues = new List<PicklistValue>();

		for(Member_Firm_Office__c mfo : [SELECT Id, Name FROM Member_Firm_Office__c WHERE Member_Firm__c=:memberFirmId]) {
			PicklistValue plv = new PicklistValue();
			plv.value = mfo.Id;
			plv.label = mfo.Name;
			mfw.primaryOfficePicklistValues.add(plv);
		}
        List<Account> accountList = [SELECT Id, Name, Parent.Name, Country1__c, Languages__c, Website_Address__c, Sectors__c,
				Twitter_Address__c, LinkedIn_Company_Page__c, Facebook_Company_Page__c, Firm_Logo_Reference__c,
				Primary_Office_Location__c, Primary_Office_Location__r.Name,
				Primary_Office_Location__r.Country__c, Primary_Office_Location__r.Street__c,
				Primary_Office_Location__r.Zip_Postal_Code__c, Primary_Office_Location__r.State_Province__c,
				Primary_Contact__c, Primary_Contact__r.Name, Primary_Contact__r.Email, Primary_Contact__r.Phone,
				Secondary_Contact__c, Secondary_Contact__r.Name, Secondary_Contact__r.Email, Secondary_Contact__r.Phone,
				Other_Social_Media_Please_list__c,
				(SELECT Id, Business_Line__c, Business_Line__r.Business_Line_Name__c
				FROM Member_Firm_Business_Lines__r WHERE Active__c = true),
				(SELECT Id FROM Member_Firm_Offices__r)
				FROM Account WHERE Id=:memberFirmId LIMIT 1];
        if(!accountList.isEmpty() && !String.isBlank(accountList[0].Firm_Logo_Reference__c)){
            List<ContentVersion> logoFile = [SELECT Id, VersionData, FileExtension, FileType 
                                             FROM ContentVersion 
                                             WHERE ContentDocumentId =: accountList[0].Firm_Logo_Reference__c LIMIT 1];
            if(!logoFile.isEmpty()){
                String fileExtension = logoFile[0].FileExtension == 'svg' ? 'svg+xml' : logoFile[0].FileExtension;
                mfw.firmLogo = 'data:image/' + fileExtension + ';base64,' + EncodingUtil.base64Encode(logoFile[0].VersionData);
            }
        }
        

		for(Account acc : accountList){

			mfw.accountId					= acc.Id;
			mfw.memberFirmName				= acc.Name;
			mfw.parentFirmName				= acc.Parent.Name;
			mfw.country						= acc.Country1__c;
			mfw.websiteAddress 				= acc.Website_Address__c;
			mfw.twitterAddress 				= acc.Twitter_Address__c;
			mfw.linkedInCompanyPage			= acc.LinkedIn_Company_Page__c;
			mfw.facebookCompanyPage 		= acc.Facebook_Company_Page__c;
                              
			mfw.officesNum                  = acc.Member_Firm_Offices__r.size();                   
           
           Set<String> businessLinesSet = new Set<String>();
           for(Member_Firm_Business_Line__c businessLine : acc.Member_Firm_Business_Lines__r){
               businessLinesSet.add(businessLine.Business_Line__r.Business_Line_Name__c);
           }
           List<String> businessLines = new List<String>(businessLinesSet);
		   businessLines.sort();
           mfw.businessLines = businessLines;

			if(acc.Primary_Office_Location__c!=null) {
				mfw.primaryOfficeLocationId = acc.Primary_Office_Location__c;
                mfw.primaryOfficeStreet = acc.Primary_Office_Location__r.Street__c;
        		mfw.primaryOfficeState = acc.Primary_Office_Location__r.State_Province__c;
                mfw.primaryOfficeZipCode = acc.Primary_Office_Location__r.Zip_Postal_Code__c;
                mfw.primaryOfficeLocationName = acc.Primary_Office_Location__r.Name;
                mfw.primaryOfficeCountry = acc.Primary_Office_Location__r.Country__c;
			}

			if(acc.Primary_Contact__c!=null) {
				mfw.primaryContactId = acc.Primary_Contact__c;
				mfw.primaryContactIdURL = '/s/contactdisplay?contactId=' + acc.Primary_Contact__c;
                mfw.primaryContactName	= acc.Primary_Contact__r.Name;
                mfw.primaryContactEmail	= acc.Primary_Contact__r.Email;
                mfw.primaryContactPhone	= acc.Primary_Contact__r.Phone;
			}


			if(acc.Secondary_Contact__c!=null) {
				mfw.secondaryContactId = acc.Secondary_Contact__c;
				mfw.secondaryContactIdURL = '/s/contactdisplay?contactId=' + acc.Secondary_Contact__c;
                mfw.secondaryContactName = acc.Secondary_Contact__r.Name;
                mfw.secondaryContactEmail	= acc.Secondary_Contact__r.Email;
                mfw.secondaryContactPhone	= acc.Secondary_Contact__r.Phone;
			}

			mfw.languages 						= buildSelectedPicklistValues(acc.Languages__c);
			mfw.sectors 						= buildSelectedPicklistValues(acc.Sectors__c);
            if(!String.isEmpty(acc.Other_Social_Media_Please_list__c)){
                 mfw.otherSocialMediaList = acc.Other_Social_Media_Please_list__c.split('\r\n');
            } else {
                mfw.otherSocialMediaList = new List<String>();
            }
			
		}

		mfw.countryPicklistValues			= buildPicklistValues(OegenHelper.getPicklistMap('Account', 'Country1__c'));//Picklist
		mfw.languagesPicklistValues 		= buildPicklistValues(OegenHelper.getPicklistMap('Account', 'Languages__c'));//Multi-Select

		return mfw;
	}

	public static List<String> buildSelectedPicklistValues(String selectedValues){

		List<String> selectedValues_List = new List<String>();
		if(selectedValues!=null){
			selectedValues_List=selectedValues.split(';');
		}
		return selectedValues_List;
	}

	public static List<PicklistValue> buildPicklistValues(Map<String, String> picklist_Map){
		List<PicklistValue> picklist_List = new List<PicklistValue>();
		for(String value :  picklist_Map.keySet()){
			PicklistValue plv = new PicklistValue();
			plv.value=value;
			plv.label=picklist_Map.get(value);
			picklist_List.add(plv);
		}
		return picklist_List;
	}


	@AuraEnabled
	public static String saveMemberFirmDetails(String accountId,
											String country,
											String languages,
											String websiteAddress,
											String twitterAddress,
											String linkedInCompanyPage,
											String facebookCompanyPage,
											String primaryOfficeLocationId,
											String primaryContactId,
											String secondaryContactId,
											String otherSocialMedia
											){

		Account memberFirmToUpsert = new Account();

		memberFirmToUpsert.Id							=	accountId;
		memberFirmToUpsert.Country1__c					=	country;
		memberFirmToUpsert.Languages__c					=	languages;
		memberFirmToUpsert.Website_Address__c			=	websiteAddress;
		memberFirmToUpsert.Twitter_Address__c			=	twitterAddress;
		memberFirmToUpsert.LinkedIn_Company_Page__c		=	linkedInCompanyPage;
		memberFirmToUpsert.Facebook_Company_Page__c		=	facebookCompanyPage;

		if(primaryOfficeLocationId!='') {
			memberFirmToUpsert.Primary_Office_Location__c = primaryOfficeLocationId;
		}

		if(primaryContactId!='') {
			memberFirmToUpsert.Primary_Contact__c = primaryContactId;
		}
		if(secondaryContactId!='') {
			memberFirmToUpsert.Secondary_Contact__c = secondaryContactId;
		}

		memberFirmToUpsert.Other_Social_Media_Please_list__c		=	otherSocialMedia;
		try {
			upsert memberFirmToUpsert;
		} catch(Exception e){
			String errorMessageForUser='There was a problem saving your changes: ';
			if(e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ')!=null){
				errorMessageForUser=e.getMessage().substringBetween('FIELD_CUSTOM_VALIDATION_EXCEPTION, ', ': ');
			} else if(e.getMessage().substringBetween('first error: ', ': ')!=null){
				errorMessageForUser=errorMessageForUser + e.getMessage().substringBetween('first error: ', ': ');
			} else {
				errorMessageForUser=e.getMessage();
			}
			//return 'There was a problem saving your changes: ' + errorMessageForUser;

			throw new AuraHandledException(errorMessageForUser);

		}
		return 'Your changes have been saved.';

	}



	public class MemberFirmWrapper {

		@AuraEnabled public Boolean userCanEditMemberFirm;
		@AuraEnabled public Id accountId;
		@AuraEnabled public String memberFirmName;
		@AuraEnabled public String parentFirmName;
		@AuraEnabled public String country;
        @AuraEnabled public String firmLogo;
        @AuraEnabled public Integer officesNum;
        
		@AuraEnabled public List<String> languages;
        @AuraEnabled public List<String> businessLines;
		@AuraEnabled public List<String> sectors;
		@AuraEnabled public String websiteAddress;
		@AuraEnabled public String twitterAddress;
		@AuraEnabled public String linkedInCompanyPage;
		@AuraEnabled public String facebookCompanyPage;
        
		@AuraEnabled public String primaryOfficeLocationId;
		@AuraEnabled public String primaryOfficeLocationName;
        @AuraEnabled public String primaryOfficeStreet;
        @AuraEnabled public String primaryOfficeCountry;
        @AuraEnabled public String primaryOfficeState;
        @AuraEnabled public String primaryOfficeZipCode;

		@AuraEnabled public String primaryContactId;
		@AuraEnabled public String primaryContactIdURL;
		@AuraEnabled public String primaryContactName;
        @AuraEnabled public String primaryContactEmail;
        @AuraEnabled public String primaryContactPhone;
        
		@AuraEnabled public String secondaryContactId;
		@AuraEnabled public String secondaryContactIdURL;
		@AuraEnabled public String secondaryContactName;
        @AuraEnabled public String secondaryContactEmail;
        @AuraEnabled public String secondaryContactPhone;
        @AuraEnabled public List<String> otherSocialMediaList;
		        
		@AuraEnabled public List<PicklistValue> countryPicklistValues;
		@AuraEnabled public List<PicklistValue> languagesPicklistValues;
		@AuraEnabled public List<PicklistValue> contactPicklistValues;
		@AuraEnabled public List<PicklistValue> primaryOfficePicklistValues;
	}

	public class PicklistValue {
		@AuraEnabled public String value;
		@AuraEnabled public String label;
		@AuraEnabled public Boolean selected;

		picklistValue(){
		}
	}


}