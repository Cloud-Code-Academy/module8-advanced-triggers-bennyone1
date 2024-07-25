
trigger AccountTrigger on Account (after insert, before insert) {
    if (Trigger.isAfter) {
        if(Trigger.isInsert) {
        AccountTriggerHandler handler = new AccountTriggerHandler();
        handler.run();
        }
    }
}