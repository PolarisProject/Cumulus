/*
    Copyright (c) 2014, Salesforce.com Foundation
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Salesforce.com Foundation nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.com Foundation
* @date 2014
* @description Controller for the address verification settings page.
 */
public with sharing class STG_PanelADDRVerification_CTRL {

    public Address_Authentication_Settings__c apiSettings { get; set; }
    public Address_Verification_Settings__c verificationSettings { get; set; }

    public String apiSettingsSaveMessage { get; private set; }
    public String verificationSettingsSaveMessage { get; private set; }

    public String apiTestEntry { get; set; }
    public String apiTestResult { get; set; }

    public Boolean skipPreviouslyVerifiedObjects { get; set; } { skipPreviouslyVerifiedObjects = true; } 
    public Boolean nowVerifying { get; private set; } { nowVerifying = false; } 
    public String bulkVerifyMessage { get; set; }


    public STG_PanelADDRVerification_CTRL() {
        apiSettings = Address_Authentication_Settings__c.getInstance();
        verificationSettings = Address_Verification_Settings__c.getInstance();
    }

    public PageReference saveApiSettings() {
        try {
            upsert apiSettings;
            apiSettingsSaveMessage = 'Saved.';
        } catch (Exception e) {
            apiSettingsSaveMessage = 'Did not save settings: ' + e.getMessage();
        }
        return null;
    }

    public PageReference saveVerificationSettings() {
        try {
            upsert verificationSettings;
            verificationSettingsSaveMessage = 'Saved.';
        } catch (Exception e) {
            verificationSettingsSaveMessage = 'Did not save settings: ' + e.getMessage();
        }
        return null;
    }

    public PageReference testApi() {
        try {
            ADDR_Zipcode_Validation_Gateway la = new ADDR_Zipcode_Validation_Gateway(apiSettings.Auth_ID__c, apiSettings.Auth_Token__c);
            ADDR_Zipcode_Validation_Gateway.Response sz = la.verifyZip( apiTestEntry );
            apiTestResult = JSON.serializePretty(sz);
        } catch (Exception e) {
            apiTestResult = e.getMessage();
        }
        return null;
    }

    public PageReference bulkVerify() {
        list<Id> apexJobIds = ADDR_Validator_Batch.verifyAllAddresses( skipPreviouslyVerifiedObjects );
        nowVerifying = true;
        bulkVerifyMessage = 'Verifying addresses. ' + JSON.serialize( apexJobIds );
        return null;
    }
}