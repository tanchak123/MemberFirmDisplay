////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
// TestClass: Test_Class_Name.cls
// - Written by JOW 2020.01 -
// Description
// 
////////////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
/* >>- Changelog -<<
* date - author - description
*/
({
	doInit: function (cmp, evt, hlp) {
		hlp.getMemberDetails(cmp,evt,hlp);
	},
    
    getMemberDetails:function(cmp, evt, hlp){
        cmp.set("v.isDataLoaded", false);
        
        let urlParams = cmp.get("v.urlParams");
        let memberFirmId;
        //Method 2
        if(urlParams.hasOwnProperty('memberFirmId')) {
            memberFirmId = urlParams.memberFirmId;
            cmp.set("v.memberFirmId", memberFirmId);
            let getDetails = cmp.get("c.getMemberFirmDetails");
            getDetails.setParams({
                "memberFirmId" : memberFirmId
            });
            getDetails.setCallback(this, function(response){
                let state = response.getState();
                if(state === "SUCCESS"){
                    let returnValue = response.getReturnValue();
                    if (returnValue != undefined) {
                        cmp.set("v.memberFirm", returnValue);
                        cmp.set("v.businessLineList", returnValue.businessLines);
                        cmp.set("v.languageList", returnValue.languages);
                        cmp.set("v.sectorList", returnValue.sectors);
                        cmp.set("v.otherSocialMediaList", returnValue.otherSocialMediaList);
                        if(returnValue.firmLogo != null){
                            cmp.set("v.firmLogoUrl", returnValue.firmLogo); 
                        }
                        cmp.set("v.isDataLoaded", true);
                    }
                }
            });
            $A.enqueueAction(getDetails);
        }
    },
    
    consoleLog: function (cmp, message, isError) {
		if (isError) {
			message = isError ? "Error: " + message : message;
			console.log(message);
		}
	}
})