public with sharing class AccountTriggerHandler extends TriggerHandler {
    public AccountTriggerHandler() {

    }

    protected override void beforeInsert() {
        List<Account> newAccounts = (List<Account>) Trigger.new;
        AccountHelper.setTypeProspect(newAccounts);
        AccountHelper.addressCopy(newAccounts);
        AccountHelper.setRating(newAccounts);

    }

    protected override void afterInsert() {
        List<Account> newAccounts = (List<Account>) Trigger.new;
        AccountHelper.defaultContact(newAccounts);

    }
}