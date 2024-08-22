 Account acc = new Account(Name = 'Testing afterDelete(notifyowners)');
        insert acc;

Opportunity testOpp = new Opportunity(
    Name = 'Test notifyowener 2',
    StageName = 'Prospecting', 
    CloseDate = Date.today().addMonths(1),
    AccountId = acc.Id
);
insert testOpp;

delete testOpp;
