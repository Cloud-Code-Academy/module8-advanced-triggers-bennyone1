/*
OpportunityTrigger Overview

This class defines the trigger logic for the Opportunity object in Salesforce. It focuses on three main functionalities:
1. Ensuring that the Opportunity amount is greater than $5000 on update.
2. Preventing the deletion of a 'Closed Won' Opportunity if the related Account's industry is 'Banking'.
3. Setting the primary contact on an Opportunity to the Contact with the title 'CEO' when updating.

Usage Instructions:
For this lesson, students have two options:
1. Use the provided `OpportunityTrigger` class as is.
2. Use the `OpportunityTrigger` from you created in previous lessons. If opting for this, students should:
    a. Copy over the code from the previous lesson's `OpportunityTrigger` into this file.
    b. Save and deploy the updated file into their Salesforce org.

Remember, whichever option you choose, ensure that the trigger is activated and tested to validate its functionality.
*/
/*trigger OpportunityTrigger on Opportunity (before update, after update, before delete) {

    /*
    * Opportunity Trigger
    * When an opportunity is updated validate that the amount is greater than 5000.
    * Trigger should only fire on update.
    */
    /*if (Trigger.isUpdate && Trigger.isBefore){
        for(Opportunity opp : Trigger.new){
            if(opp.Amount < 5000){
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }
    }

    /*
    * Opportunity Trigger
    * When an opportunity is deleted prevent the deletion of a closed won opportunity if the account industry is 'Banking'.
    * Trigger should only fire on delete.
    */
    /*if (Trigger.isDelete){
        //Account related to the opportunities 
        Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, Industry FROM Account WHERE Id IN (SELECT AccountId FROM Opportunity WHERE Id IN :Trigger.old)]);
        for(Opportunity opp : Trigger.old){
            if(opp.StageName == 'Closed Won'){
                if(accounts.get(opp.AccountId).Industry == 'Banking'){
                    opp.addError('Cannot delete a closed won opportunity for a banking account');
                }
            }
        }
    }

    /*
    * Opportunity Trigger
    * When an opportunity is updated set the primary contact on the opportunity to the contact with the title of 'CEO'.
    * Trigger should only fire on update.
    */
    /*if (Trigger.isUpdate && Trigger.isBefore){
        //Get contacts related to the opportunity account
        Set<Id> accountIds = new Set<Id>();
        for(Opportunity opp : Trigger.new){
            accountIds.add(opp.AccountId);
        }
        
        Map<Id, Contact> contacts = new Map<Id, Contact>([SELECT Id, FirstName, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO' ORDER BY FirstName ASC]);
        Map<Id, Contact> accountIdToContact = new Map<Id, Contact>();

        for (Contact cont : contacts.values()) {
            if (!accountIdToContact.containsKey(cont.AccountId)) {
                accountIdToContact.put(cont.AccountId, cont);
            }
        }

        for(Opportunity opp : Trigger.new){
            if(opp.Primary_Contact__c == null){
                if (accountIdToContact.containsKey(opp.AccountId)){
                    opp.Primary_Contact__c = accountIdToContact.get(opp.AccountId).Id;
                }
            }
        }
    }    
}*/
//----------------------------------------------------------------------------------------------------------------------------------------------Where I copied the anotheropptrigger below what was already in this file
/*
AnotherOpportunityTrigger Overview

This trigger was initially created for handling various events on the Opportunity object. It was developed by a prior developer and has since been noted to cause some issues in our org.

IMPORTANT:
- This trigger does not adhere to Salesforce best practices.
- It is essential to review, understand, and refactor this trigger to ensure maintainability, performance, and prevent any inadvertent issues.

ISSUES:
Avoid nested for loop - 1 instance
Avoid DML inside for loop - 1 instance
Bulkify Your Code - 1 instance
Avoid SOQL Query inside for loop - 2 instances
Stop recursion - 1 instance

RESOURCES: 
https://www.salesforceben.com/12-salesforce-apex-best-practices/
https://developer.salesforce.com/blogs/developer-relations/2015/01/apex-best-practices-15-apex-commandments
*/
trigger OpportunityTrigger on Opportunity (
    before insert, 
    after insert, 
    before update, 
    after update, 
    before delete, 
    after delete, 
    after undelete
) {
    OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
    
    // Handle before insert
    if (Trigger.isBefore && Trigger.isInsert) {
        handler.run();
    }
    
    // Handle after insert
    else if (Trigger.isAfter && Trigger.isInsert) {
        handler.run();
    }
    
    // Handle before update
    else if (Trigger.isBefore && Trigger.isUpdate) {
        handler.run();
    }
    
    // Handle after update
    else if (Trigger.isAfter && Trigger.isUpdate) {
        handler.run();
    }

    // Handle before delete
    else if (Trigger.isBefore && Trigger.isDelete) {
        handler.run();
    }
     // Handle after delete
     else if (Trigger.isAfter && Trigger.isDelete) {
        handler.run();
    }
}






    /*if (Trigger.isAfter){
        if (Trigger.isInsert){
            // Create a new Task for newly inserted Opportunities
            for (Opportunity opp : Trigger.new){
                Task tsk = new Task();
                tsk.Subject = 'Call Primary Contact';
                tsk.WhatId = opp.Id;
                tsk.WhoId = opp.Primary_Contact__c;
                tsk.OwnerId = opp.OwnerId;
                tsk.ActivityDate = Date.today().addDays(3);
                insert tsk;
            }
        } else if (Trigger.isUpdate){
            // Append Stage changes in Opportunity Description
            for (Opportunity opp : Trigger.new){
                for (Opportunity oldOpp : Trigger.old){
                    if (opp.StageName != null){
                        opp.Description += '\n Stage Change:' + opp.StageName + ':' + DateTime.now().format();
                    }
                }                
            }
            update Trigger.new;
        }
        // Send email notifications when an Opportunity is deleted 
        else if (Trigger.isDelete){
            notifyOwnersOpportunityDeleted(Trigger.old);
            
        } 
        // Assign the primary contact to undeleted Opportunities
        else if (Trigger.isUndelete){
            assignPrimaryContact(Trigger.newMap);
        }
    }

    /*
    notifyOwnersOpportunityDeleted:
    - Sends an email notification to the owner of the Opportunity when it gets deleted.
    - Uses Salesforce's Messaging.SingleEmailMessage to send the email.
    */
   /* private static void notifyOwnersOpportunityDeleted(List<Opportunity> opps) {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for (Opportunity opp : opps){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {[SELECT Id, Email FROM User WHERE Id = :opp.OwnerId].Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Opportunity Deleted : ' + opp.Name);
            mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
            mails.add(mail);
        }        
        
        try {
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }

    /*
    assignPrimaryContact:
    - Assigns a primary contact with the title of 'VP Sales' to undeleted Opportunities.
    - Only updates the Opportunities that don't already have a primary contact.
    */
    /*private static void assignPrimaryContact(Map<Id,Opportunity> oppNewMap) {        
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        for (Opportunity opp : oppNewMap.values()){            
            Contact primaryContact = [SELECT Id, AccountId FROM Contact WHERE Title = 'VP Sales' AND AccountId = :opp.AccountId LIMIT 1];
            if (opp.Primary_Contact__c == null){
                Opportunity oppToUpdate = new Opportunity(Id = opp.Id);
                oppToUpdate.Primary_Contact__c = primaryContact.Id;
                oppMap.put(opp.Id, oppToUpdate);
            }
        }
        update oppMap.values();
    }*/
