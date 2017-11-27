/**
 * Developed by Doug Ayers, douglascayers.com
 * for Jessica Pasley, https://twitter.com/JessicaPasley/status/934885281370656768
 */
@IsTest
private class ConcatenateSObjectFieldValuesServiceTest {

    @IsTest
    static void test_concatenate_fields() {

        Account acct1 = new Account(
            name = 'Test Account',
            AnnualRevenue = 500,
            NumberOfEmployees = 12,
            Rating = 'Hot'
        );

        insert acct1;

        Test.startTest();

        ConcatenateSObjectFieldValuesService.Request req = new ConcatenateSObjectFieldValuesService.Request();
        req.recordId = acct1.id;
        req.fieldNames = 'AnnualRevenue, NumberOfEmployees, Rating';

        List<ConcatenateSObjectFieldValuesService.Response> responses = ConcatenateSObjectFieldValuesService.execute( new ConcatenateSObjectFieldValuesService.Request[] { req } );

        Test.stopTest();

        Map<String, SObjectField> fieldsMap = Account.SObjectType.getDescribe().fields.getMap();
        String expectedString = acct1.AnnualRevenue.format() + ' ' + fieldsMap.get( 'AnnualRevenue' ).getDescribe().getLabel() + req.delimiter + ' ' +
                                acct1.NumberOfEmployees.format() + ' ' + fieldsMap.get( 'NumberOfEmployees' ).getDescribe().getLabel() + ' ' + req.lastDelimiter + ' ' +
                                acct1.Rating + ' ' + fieldsMap.get( 'Rating' ).getDescribe().getLabel();

        System.assertEquals( 1, responses.size() );
        System.assertEquals( expectedString, responses[0].concatenatedString );

    }

    @IsTest
    static void test_ignore_values() {

        Account acct1 = new Account(
            name = 'Test Account',
            AnnualRevenue = null,
            NumberOfEmployees = 12,
            Rating = 'Hot'
        );

        insert acct1;

        Test.startTest();

        ConcatenateSObjectFieldValuesService.Request req = new ConcatenateSObjectFieldValuesService.Request();
        req.recordId = acct1.id;
        req.fieldNames = 'AnnualRevenue, NumberOfEmployees, Rating';
        req.ignoreValues = 'null, 0';

        List<ConcatenateSObjectFieldValuesService.Response> responses = ConcatenateSObjectFieldValuesService.execute( new ConcatenateSObjectFieldValuesService.Request[] { req } );

        Test.stopTest();

        Map<String, SObjectField> fieldsMap = Account.SObjectType.getDescribe().fields.getMap();
        String expectedString = acct1.NumberOfEmployees.format() + ' ' + fieldsMap.get( 'NumberOfEmployees' ).getDescribe().getLabel() + ' ' + req.lastDelimiter + ' ' +
                                acct1.Rating + ' ' + fieldsMap.get( 'Rating' ).getDescribe().getLabel();

        System.assertEquals( 1, responses.size() );
        System.assertEquals( expectedString, responses[0].concatenatedString );

    }

    @IsTest
    static void test_delimiters() {

        Account acct1 = new Account(
            name = 'Test Account',
            AnnualRevenue = 500,
            NumberOfEmployees = 12,
            Rating = 'Hot'
        );

        insert acct1;

        Test.startTest();

        ConcatenateSObjectFieldValuesService.Request req = new ConcatenateSObjectFieldValuesService.Request();
        req.recordId = acct1.id;
        req.fieldNames = 'AnnualRevenue, NumberOfEmployees, Rating';
        req.delimiter = '|';
        req.lastDelimiter = '$';

        List<ConcatenateSObjectFieldValuesService.Response> responses = ConcatenateSObjectFieldValuesService.execute( new ConcatenateSObjectFieldValuesService.Request[] { req } );

        Test.stopTest();

        Map<String, SObjectField> fieldsMap = Account.SObjectType.getDescribe().fields.getMap();
        String expectedString = acct1.AnnualRevenue.format() + ' ' + fieldsMap.get( 'AnnualRevenue' ).getDescribe().getLabel() + req.delimiter + ' ' +
                                acct1.NumberOfEmployees.format() + ' ' + fieldsMap.get( 'NumberOfEmployees' ).getDescribe().getLabel() + ' ' + req.lastDelimiter + ' ' +
                                acct1.Rating + ' ' + fieldsMap.get( 'Rating' ).getDescribe().getLabel();

        System.assertEquals( 1, responses.size() );
        System.assertEquals( expectedString, responses[0].concatenatedString );

    }

}