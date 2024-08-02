/*
AccountHelper Overview

The `AccountHelper` class is designed to provide helper methods that assist in performing specific operations on Account records. 
This class is intended to modularize the logic used in the `AccountTrigger` to ensure separation of concerns, improve readability, and ease maintenance. 

This class is currently stubbed out. As part of this exercise, you are expected to:
1. Implement the method bodies to carry out the specified operations on Account records.
2. Refactor the `AccountTrigger` to utilize the methods provided in this `AccountHelper` class.

Methods:
- `setTypeProspect(SObject objects)`: 
    - Purpose: Update the 'Type' field of the given Account record to 'Prospect' if it's not already set.
    - Note: You'll likely need to adjust the method signature to accept the necessary parameters.

- `addressCopy()`: 
    - Purpose: Copy the shipping address of the Account to its billing address. 
    - Note: You'll likely need to adjust the method signature to accept the necessary parameters.

- `setRating`: 
    - Purpose: Evaluate certain conditions on the Account and assign a rating based on that evaluation. You'll need to define the method's signature and implement its logic.

- `defaultContact`: 
    - Purpose: Create a default contact related to the Account after the Account is inserted. You'll need to define the method's signature and implement its logic.

Remember:
Always ensure that your helper methods are bulk-safe to handle multiple records efficiently. 
*/
public with sharing class AccountHelper {
    
    public static void setTypeProspectAfterInsert(List<Account> newAccounts) {
        List<Account> accountsToUpdate = new List<Account>();
            for (Account acc : newAccounts) {
                if (acc.Type == null) {
                    Account accToUpdateAfterInsert = new Account(Id = acc.Id , Type = 'Prospect');
                    accountsToUpdate.add(accToUpdateAfterInsert);
                }
            }
    
            if (!accountsToUpdate.isEmpty()) {
                update as system accountsToUpdate;
            }
        }
    
    public static void addressCopyAfterInsert(List<Account> newAccounts) {
        List<Account> accountsToUpdate = new List<Account>();
        for (Account acc : newAccounts) {
            if (acc.ShippingStreet != null ||
                acc.ShippingCity != null ||
                acc.ShippingState != null ||
                acc.ShippingPostalCode != null ||
                acc.ShippingCountry != null) {
                    
                Account accToUpdate = new Account(
                    Id = acc.Id,
                    BillingStreet = acc.ShippingStreet,
                    BillingCity = acc.ShippingCity,
                    BillingState = acc.ShippingState,
                    BillingPostalCode = acc.ShippingPostalCode,
                    BillingCountry = acc.ShippingCountry
                );
                accountsToUpdate.add(accToUpdate);
            }            
        }
            update as system accountsToUpdate;
    }
    
        public static void setRating(List<Account> newAccounts) {
            List<Account> accountsToUpdate = new List<Account>();
            for (Account acc : newAccounts) {
            if (acc.Phone != null && acc.Website != null && acc.Fax != null) {
                Account accToUpdate = new Account(
                    Id = acc.Id,
                    Phone = acc.Phone,
                    Website = acc.Website,
                    Fax = acc.Fax,
                    Rating = 'Hot'
                );
                accountsToUpdate.add(accToUpdate);
            }
        }
        update as system accountsToUpdate;
    }
    
        public static void defaultContact(List<Account> newAccounts) {
            List<Contact> defaultContactsToCreate = new List<Contact>();
            for (Account acc : newAccounts) {
                Contact con = new Contact(
                    AccountId = acc.Id,
                    LastName = 'DefaultContact',
                    Email = 'default@email.com' 
                );
                defaultContactsToCreate.add(con);
            }
            insert as system defaultContactsToCreate;
        }
    }