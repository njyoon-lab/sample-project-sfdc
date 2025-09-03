@isTest
private class AccountServiceTest {
    @isTest
    static void testCreateOpportunitiesForAccounts() {
        // Create test accounts
        List<Account> testAccounts = new List<Account>();
        for (Integer i = 0; i < 5; i++) {
            testAccounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert testAccounts;

        // Call the method to create opportunities
        Test.startTest();
        AccountService.createOpportunitiesForAccounts(testAccounts);
        Test.stopTest();

        // Verify that opportunities were created
        List<Opportunity> createdOpps = [
            SELECT Id, Name, AccountId, CloseDate, StageName
            FROM Opportunity
            WHERE AccountId IN :testAccounts
        ];
        System.assertEquals(5, createdOpps.size(), 'Five opportunities should have been created.');

        // Verify opportunity details
        for (Opportunity opp : createdOpps) {
            System.assert(opp.Name.startsWith('Test Account'), 'Opportunity name should start with account name.');
            System.assertEquals(Date.today().addMonths(1), opp.CloseDate, 'Close date should be one month from today.');
            System.assertEquals('Prospecting', opp.StageName, 'Stage name should be "Prospecting".');
        }
    }

    @isTest
    static void testCreateOpportunitiesForAccounts_NoDuplicateOpportunities() {
        // Create a test account
        Account testAccount = new Account(Name = 'Unique Account');
        insert testAccount;

        // Create an existing open opportunity for this account
        Opportunity existingOpp = new Opportunity(
            Name = 'Existing Opportunity',
            AccountId = testAccount.Id,
            CloseDate = Date.today().addMonths(1),
            StageName = 'Prospecting'
        );
        insert existingOpp;

        // Call the method to create opportunities
        Test.startTest();
        AccountService.createOpportunitiesForAccounts(new List<Account>{testAccount});
        Test.stopTest();

        // Verify that no new opportunity was created
        List<Opportunity> opps = [
            SELECT Id
            FROM Opportunity
            WHERE AccountId = :testAccount.Id
        ];
        System.assertEquals(1, opps.size(), 'No new opportunity should have been created.');
    }

    @isTest
    static void testCreateOpportunitiesForAccounts_EmptyList() {
        try {
            Test.startTest();
            AccountService.createOpportunitiesForAccounts(new List<Account>());
            Test.stopTest();
            System.assert(false, 'Expected an exception for empty account list.');
        } catch (AccountService.AccountServiceException e) {
            System.assertEquals('Accounts list is null or empty.', e.getMessage()); // Adjusted to match the new exception message              
            System.Assert.isTrue(true, 'Expected an exception for empty account list.');
        }
    }   
}