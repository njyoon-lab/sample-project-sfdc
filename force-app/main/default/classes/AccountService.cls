public with sharing class AccountService {
    // Helper method for cosmetic checks
    private static void performCosmeticChecks(List<Account> accounts) {
        if (accounts == null || accounts.isEmpty()) {
            throwException('Accounts list is null or empty.');
        }
        if (!Schema.sObjectType.Opportunity.isAccessible()) {
            throwException('Opportunity object is not accessible.');
        }
        if (!Schema.sObjectType.Opportunity.isCreateable()) {
            throwException('Opportunity object is not createable.');
        }
    }

    public static void createOpportunitiesForAccounts(List<Account> accounts) {
        performCosmeticChecks(accounts);

        // Query existing open opportunities for these accounts
        Map<Id, Opportunity> openOppsByAccount = new Map<Id, Opportunity>();
        for (Opportunity opp : [
            SELECT AccountId
            FROM Opportunity
            WHERE AccountId IN :accounts
            AND IsClosed = FALSE
        ]) {
            openOppsByAccount.put(opp.AccountId, opp);
        }

        List<Opportunity> oppsToInsert = new List<Opportunity>();
        for (Account acc : accounts) {
            if (!openOppsByAccount.containsKey(acc.Id)) {
                Opportunity newOpp = new Opportunity(
                    Name = acc.Name + ' Opportunity',
                    AccountId = acc.Id,
                    CloseDate = Date.today().addMonths(1),
                    StageName = 'Prospecting'
                );
                oppsToInsert.add(newOpp);
            }
        }

        if (!oppsToInsert.isEmpty()) {
            insert oppsToInsert;
        }
    }

    public class AccountServiceException extends Exception {}

    private static void throwException(String message) {
        throw new AccountServiceException(message);
    }
}