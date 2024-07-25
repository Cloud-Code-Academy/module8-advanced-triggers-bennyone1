
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