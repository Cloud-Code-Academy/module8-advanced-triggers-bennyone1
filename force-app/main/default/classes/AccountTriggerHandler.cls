public with sharing class AccountTriggerHandler extends TriggerHandler {
    public AccountTriggerHandler() {

    }

    protected override void afterInsert() {
        List<Account> newAccounts = (List<Account>) Trigger.new;
        AccountHelper.defaultContact(newAccounts);
        AccountHelper.addressCopyAfterInsert(newAccounts);
        AccountHelper.setRating(newAccounts);
        AccountHelper.setTypeProspectAfterInsert(newAccounts);

    }
}