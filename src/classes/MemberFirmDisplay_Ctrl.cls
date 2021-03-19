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
	public static MemberFirmWrapper getMemberFirmDetails(Id memberFirmId) {
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
        List<Account> accountList = [SELECT Id, Name, Parent.Name, Country1__c, Languages__c, General_Telephone_number__c, General_Email_Address__c, Website_Address__c, Sectors__c,
						  Twitter_Address__c, LinkedIn_Company_Page__c, Facebook_Company_Page__c, Primary_Office_Location__c, Primary_Office_Location__r.Name, Primary_Office_Location__r.Country__c, Primary_Office_Location__r.Street__c, Primary_Office_Location__r.Zip_Postal_Code__c, Primary_Office_Location__r.State_Province__c,
				  		  Primary_Contact__c, Primary_Contact__r.Name, Primary_Contact__r.Email, Primary_Contact__r.Phone, 
                          Secondary_Contact__c, Secondary_Contact__r.Name, Secondary_Contact__r.Email, Secondary_Contact__r.Phone, 
                          Administrative_Contact__c, Administrative_Contact__r.Name, Administrative_Contact__r.Email, Administrative_Contact__r.Phone,
						  Marketing_Contact__c, Marketing_Contact__r.Name, Human_Resources_Contact__c, Human_Resources_Contact__r.Name,
						  IT_Contact__c, IT_Contact__r.Name, Head_of_Audit__c, Head_of_Audit__r.Name, IFRS_Contact__c, IFRS_Contact__r.Name,
						  Quality_Control_Contact__c, Quality_Control_Contact__r.Name, Designated_contact_for_factsheet__c, Designated_contact_for_factsheet__r.Name,
						  Name_of_person_completing_factsheet__c, Name_of_person_completing_factsheet__r.Name,
						  Permission_to_disclose_factsheet_data__c, Other_Social_Media_Please_list__c,
						  BillingStreet, BillingCity, BillingState, BillingCountry, BillingPostalCode,
						  BillingAddress, Firm_Logo_Reference__c, 
                          (SELECT Id, Business_Line__c, Business_Line__r.Business_Line_Name__c FROM Member_Firm_Business_Lines__r WHERE Active__c = true),
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
        

		for(Account acc : accountList) {

			mfw.accountId					= acc.Id;
			mfw.memberFirmName				= acc.Name;
			mfw.parentFirmName				= acc.Parent.Name;
			mfw.country						= acc.Country1__c;
			mfw.generalPhoneNumber 			= acc.General_Telephone_number__c;
			mfw.generalEmailAddress 		= acc.General_Email_Address__c;
			mfw.websiteAddress 				= acc.Website_Address__c;
			mfw.twitterAddress 				= acc.Twitter_Address__c;
			mfw.linkedInCompanyPage			= acc.LinkedIn_Company_Page__c;
			mfw.facebookCompanyPage 		= acc.Facebook_Company_Page__c;
                              
			mfw.officesNum                  = acc.Member_Firm_Offices__r.size();                   
           
           Set<String> businessLinesSet = new Set<String>();
           for(Member_Firm_Business_Line__c businessLine : acc.Member_Firm_Business_Lines__r) {
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
				//mfw.primaryOfficeLocationIdURL = '/s/contactdisplay?contactId=' + acc.Primary_Office_Location__c;
			}
			//mfw.primaryOfficeLocationName 	= acc.Primary_Office_Location__r.Name;

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
			

			if(acc.Administrative_Contact__c!=null) {
				mfw.adminContactId = acc.Administrative_Contact__c;
				mfw.adminContactIdURL = '/s/contactdisplay?contactId=' + acc.Administrative_Contact__c;
                mfw.adminContactName = acc.Administrative_Contact__r.Name;
                mfw.adminContactEmail	= acc.Administrative_Contact__r.Email;
                mfw.adminContactPhone	= acc.Administrative_Contact__r.Phone;
			}
			

			if(acc.Marketing_Contact__c!=null) {
				mfw.marketingContactId = acc.Marketing_Contact__c;
				mfw.marketingContactIdURL = '/s/contactdisplay?contactId=' + acc.Marketing_Contact__c;
                mfw.marketingContactName = acc.Marketing_Contact__r.Name;
			}
			

			if(acc.Human_Resources_Contact__c!=null) {
				mfw.hrContactId = acc.Human_Resources_Contact__c;
				mfw.hrContactIdURL = '/s/contactdisplay?contactId=' + acc.Human_Resources_Contact__c;
                mfw.hrContactName = acc.Human_Resources_Contact__r.Name;
			}
			

			if(acc.IT_Contact__c!=null) {
				mfw.itContactId = acc.IT_Contact__c;
				mfw.itContactIdURL = '/s/contactdisplay?contactId=' + acc.IT_Contact__c;
			}
			mfw.itContactName = acc.IT_Contact__r.Name;

			if(acc.Head_of_Audit__c!=null) {
				mfw.headOfAuditId = acc.Head_of_Audit__c;
				mfw.headOfAuditIdURL = '/s/contactdisplay?contactId=' + acc.Head_of_Audit__c;
			}
			mfw.headOfAuditName	= acc.Head_of_Audit__r.Name;

			if(acc.IFRS_Contact__c!=null) {
				mfw.ifrsContactId = acc.IFRS_Contact__c;
				mfw.ifrsContactIdURL = '/s/contactdisplay?contactId=' + acc.IFRS_Contact__c;
			}
			mfw.ifrsContactName	= acc.IFRS_Contact__r.Name;

			mfw.qualityControlContactId			= acc.Quality_Control_Contact__c;
			mfw.qualityControlContactName		= acc.Quality_Control_Contact__r.Name;

			if(acc.Designated_contact_for_factsheet__c!=null) {
				mfw.designatedContactId = acc.Designated_contact_for_factsheet__c;
				mfw.designatedContactIdURL = '/s/contactdisplay?contactId=' + acc.Designated_contact_for_factsheet__c;
			}
			mfw.designatedContactName			= acc.Designated_contact_for_factsheet__r.Name;

			if(acc.Name_of_person_completing_factsheet__c!=null) {
				mfw.personCompletingFactsheetId = acc.Name_of_person_completing_factsheet__c;
				mfw.personCompletingFactsheetIdURL = '/s/contactdisplay?contactId=' + acc.Name_of_person_completing_factsheet__c;
			}
			mfw.personCompletingFactsheetName	= acc.Name_of_person_completing_factsheet__r.Name;
			mfw.permissionToDisclose			= acc.Permission_to_disclose_factsheet_data__c;
			mfw.otherSocialMedia				= acc.Other_Social_Media_Please_list__c;
			//mfw.billingAddress				= acc.BillingAddress;
			mfw.billingStreet					= acc.BillingStreet;
			mfw.billingCity						= acc.BillingCity;
			mfw.billingState					= acc.BillingState;
			mfw.billingCountry					= acc.BillingCountry;
			mfw.billingPostcode					= acc.BillingPostalCode;

			mfw.languages 						= buildSelectedPicklistValues(acc.Languages__c);
			mfw.sectors 						= buildSelectedPicklistValues(acc.Sectors__c);
            if(!String.isEmpty(acc.Other_Social_Media_Please_list__c)){
                 mfw.otherSocialMediaList = acc.Other_Social_Media_Please_list__c.split('\r\n');
            } else {
                mfw.otherSocialMediaList = new List<String>();
            }
			
		}

		mfw.countryPicklistValues			= buildPicklistValues(OegenHelper.getPicklistMap('Account', 'Country1__c'));//Picklist
		mfw.permissionPicklistValues		= buildPicklistValues(OegenHelper.getPicklistMap('Account', 'Permission_to_disclose_factsheet_data__c'));//Picklist
		mfw.languagesPicklistValues 		= buildPicklistValues(OegenHelper.getPicklistMap('Account', 'Languages__c'));//Multi-Select

		return mfw;
	}

	public static List<String> buildSelectedPicklistValues(String selectedValues) {

		List<String> selectedValues_List = new List<String>();
		if(selectedValues!=null){
			selectedValues_List=selectedValues.split(';');
		}
		return selectedValues_List;
	}

	public static List<PicklistValue> buildPicklistValues(Map<String, String> picklist_Map) {
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
											String generalPhoneNumber,
											String generalEmailAddress,
											String websiteAddress,
											String twitterAddress,
											String linkedInCompanyPage,
											String facebookCompanyPage,
											String primaryOfficeLocationId,
											String primaryContactId,
											String secondaryContactId,
											String adminContactId,
											String marketingContactId,
											String hrContactId,
											String itContactId,
											String headOfAuditId,
											String ifrsContactId,
											String qualityControlContactId,
											String designatedContactId,
											String personCompletingFactsheetId,
											String permissionToDisclose,
											String otherSocialMedia,
											////mfw.billingAddress				= acc.BillingAddress;
											String billingStreet,
											String billingCity,
											String billingState,
											String billingCountry,
											String billingPostcode

											) {

		Account memberFirmToUpsert = new Account();

		memberFirmToUpsert.Id							=	accountId;
		memberFirmToUpsert.Country1__c					=	country;
		memberFirmToUpsert.Languages__c					=	languages;
		memberFirmToUpsert.General_Telephone_number__c	=	generalPhoneNumber;
		memberFirmToUpsert.General_Email_Address__c		=	generalEmailAddress;
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
		if(adminContactId!='') {
			memberFirmToUpsert.Administrative_Contact__c = adminContactId;
		}
		if(marketingContactId!='') {
			memberFirmToUpsert.Marketing_Contact__c = marketingContactId;
		}
		if(hrContactId!='') {
			memberFirmToUpsert.Human_Resources_Contact__c = hrContactId;
		}
		if(itContactId!='') {
			memberFirmToUpsert.IT_Contact__c = itContactId;
		}
		if(headOfAuditId!='') {
			memberFirmToUpsert.Head_of_Audit__c = headOfAuditId;
		}
		if(ifrsContactId!='') {
			memberFirmToUpsert.IFRS_Contact__c = ifrsContactId;
		}
		if(qualityControlContactId!='') {
			memberFirmToUpsert.Quality_Control_Contact__c = qualityControlContactId;
		}
		if(designatedContactId!='') {
			memberFirmToUpsert.Designated_contact_for_factsheet__c = designatedContactId;
		}
		if(personCompletingFactsheetId!='') {
			memberFirmToUpsert.Name_of_person_completing_factsheet__c = personCompletingFactsheetId;
		}

		memberFirmToUpsert.Permission_to_disclose_factsheet_data__c	=	permissionToDisclose;
		memberFirmToUpsert.Other_Social_Media_Please_list__c		=	otherSocialMedia;

		//memberFirmToUpsert.BillingAddress	=	billingAddress;
		memberFirmToUpsert.BillingStreet		=	billingStreet;
		memberFirmToUpsert.BillingCity			=	billingCity;
		memberFirmToUpsert.BillingState			=	billingState;
		memberFirmToUpsert.BillingCountry		=	billingCountry;
		memberFirmToUpsert.BillingPostalCode	=	billingPostcode;

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



	public class MemberFirmWrapper{

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
        
		@AuraEnabled public String generalPhoneNumber;
		@AuraEnabled public String generalEmailAddress;
		@AuraEnabled public String websiteAddress;
		@AuraEnabled public String twitterAddress;
		@AuraEnabled public String linkedInCompanyPage;
		@AuraEnabled public String facebookCompanyPage;
        
		@AuraEnabled public String primaryOfficeLocationId;
		@AuraEnabled public String primaryOfficeLocationIdURL;
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
        
		@AuraEnabled public String adminContactId;
		@AuraEnabled public String adminContactIdURL;
		@AuraEnabled public String adminContactName;
        @AuraEnabled public String adminContactEmail;
        @AuraEnabled public String adminContactPhone;
        
		@AuraEnabled public String marketingContactId;
		@AuraEnabled public String marketingContactIdURL;
		@AuraEnabled public String marketingContactName;
		@AuraEnabled public String hrContactId;
		@AuraEnabled public String hrContactIdURL;
		@AuraEnabled public String hrContactName;
		@AuraEnabled public String itContactId;
		@AuraEnabled public String itContactIdURL;
		@AuraEnabled public String itContactName;
		@AuraEnabled public String headOfAuditId;
		@AuraEnabled public String headOfAuditIdURL;
		@AuraEnabled public String headOfAuditName;
		@AuraEnabled public String ifrsContactId;
		@AuraEnabled public String ifrsContactIdURL;
		@AuraEnabled public String ifrsContactName;
		@AuraEnabled public String qualityControlContactId;
		//@AuraEnabled public String qualityControlContactIdURL;
		@AuraEnabled public String qualityControlContactName;
		@AuraEnabled public String designatedContactId;
		@AuraEnabled public String designatedContactIdURL;
		@AuraEnabled public String designatedContactName;
		@AuraEnabled public String personCompletingFactsheetId;
		@AuraEnabled public String personCompletingFactsheetIdURL;
		@AuraEnabled public String personCompletingFactsheetName;

		@AuraEnabled public String permissionToDisclose;
		@AuraEnabled public String otherSocialMedia;
        @AuraEnabled public List<String> otherSocialMediaList;
		@AuraEnabled public String billingStreet;
		@AuraEnabled public String billingCity;
		@AuraEnabled public String billingState;
		@AuraEnabled public String billingCountry;
		@AuraEnabled public String billingPostcode;
		//@AuraEnabled public String billingAddress;
		        
		@AuraEnabled public List<PicklistValue> countryPicklistValues;
		@AuraEnabled public List<PicklistValue> languagesPicklistValues;
		@AuraEnabled public List<PicklistValue> contactPicklistValues;
		@AuraEnabled public List<PicklistValue> primaryOfficePicklistValues;
		@AuraEnabled public List<PicklistValue> permissionPicklistValues;
	}

	public class PicklistValue {
		@AuraEnabled public String value;
		@AuraEnabled public String label;
		@AuraEnabled public Boolean selected;

		picklistValue(){
		}
	}


}