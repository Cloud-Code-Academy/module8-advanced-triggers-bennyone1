public with sharing class AnotherOpportunityHelper extends TriggerHandler {
    public AnotherOpportunityHelper() {

    }
    public static void setType(List<Opportunity> opportunities) {
    for (Opportunity opp : opportunities) {
        if (opp.Type == null){
            opp.Type = 'New Customer';
        }
    }
}
    public static void validateCloseOpportunity(List<Opportunity> opportunities) {
        for (Opportunity opp : opportunities) {
                if (opp.IsClosed) {
                    opp.addError('Cannot delete closed opportunity');
                    }
                }
            }
        }
    