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
	doInit : function(component, event, helper) {
        try {
			helper.doInit(component, event, helper);
		} catch (e) {
            helper.consoleLog(component, e, true);
		}
		
	},
    
    goToOffices : function(component, event, helper) {
        component.set("v.selTabId", "officeTab");
    }

})