/**
 * Developed by Doug Ayers, douglascayers.com
 * for Jessica Pasley, https://twitter.com/JessicaPasley/status/934885281370656768
 */
public with sharing class ConcatenateSObjectFieldValuesService {

    @InvocableMethod(
        label = 'Concatenate Fields'
    )
    public static List<Response> execute( List<Request> requests ) {

        List<Response> responses = new List<Response>();

        // bulkify query by identifying all the record ids and fields to query once
        // assumption is that record ids of all requests are of the same sobject type
        Set<ID> recordIds = new Set<ID>();
        Set<String> fieldNames = new Set<String>();
        SObjectType recordSObjectType = null;

        for ( Request req : requests ) {

            System.debug( req );

            recordSObjectType = req.recordId.getSobjectType();
            recordIds.add( req.recordId );
            fieldNames.addAll( req.fieldNames.replaceAll(' ', '').split(',') );

        }

        String querySelectClause = String.join( new List<String>( fieldNames ), ',' );
        String queryFromClause = recordSObjectType.getDescribe().getName();
        String queryWhereClause = 'Id IN ( \'' + String.join( new List<ID>( recordIds ), '\',\'' ) + '\' )';

        String query = String.format(
            ' SELECT {0} FROM {1} WHERE {2} ',
            new String[] { querySelectClause, queryFromClause, queryWhereClause }
        );

        Map<ID, SObject> recordsMap = new Map<ID, SObject>( Database.query( query ) );

        Map<String, SObjectField> fieldsMap = recordSObjectType.getDescribe().fields.getMap();

        for ( Request req : requests ) {

            SObject record = recordsMap.get( req.recordId );

            // values to concatenate together
            List<String> values = new List<String>();

            Set<String> ignoreValues = ( req.ignoreValues != null ) ? ( new Set<String>( req.ignoreValues.replaceAll( ' ', '' ).split( ',' ) ) ) : new Set<String>();
            System.debug( 'ignoreValues=' + ignoreValues );

            for ( String fieldName : req.fieldNames.split( ',' ) ) {

                // trim any whitespace around field name from csv list
                fieldName = fieldName.trim();

                // obtain the field value from the record
                Object fieldValue = record.get( fieldName );

                // convert null to string for ignore value comparison
                // https://twitter.com/DouglasCAyers/status/934925569732562945
                fieldValue = ( fieldValue == null ? 'null' : fieldValue );

                System.debug( fieldName + '=' + fieldValue );
                System.debug( 'ignored? ' + ignoreValues.contains( String.valueOf( fieldValue ) ) );

                // skip if the field value is ignorable
                if ( !ignoreValues.contains( String.valueOf( fieldValue ) ) ) {

                    // special handling, format numbers in user's locale
                    if ( fieldValue instanceof Decimal ) {
                        fieldValue = ( (Decimal) fieldValue ).format();
                    }

                    values.add( fieldValue + ' ' + ( fieldsMap.get( fieldName ).getDescribe().getLabel() ) );

                }

            }

            System.debug( 'valuesToConcatenate=' + values );

            // now concatenate the list of values into one string
            String valuesString = '';
            String delimiter = '';

            for ( Integer i = 0; i < values.size(); i++ ) {
                valuesString += delimiter + values[i];
                delimiter = ( ( i < values.size() - 2 ) ? req.delimiter : ' ' + req.lastDelimiter ) + ' ';
            }

            // create response
            Response res = new Response();
            res.concatenatedString = valuesString;

            System.debug( res );

            responses.add( res );

        }

        return responses;
    }

    public class Request {

        @InvocableVariable(
            label = 'Record ID'
            required = true
        )
        public ID recordId;

        @InvocableVariable(
            label = 'Field API Names'
            description = 'Comma-delimited list of fields (e.g. FieldA__c, FieldB__c)'
            required = true
        )
        public String fieldNames;

        @InvocableVariable(
            label = 'Delimiter'
            Description = 'Text that separates two values. Default is comma ",".'
        )
        public String delimiter = ',';

        @InvocableVariable(
            label = 'Last Delimiter'
            Description = 'Text that separates the second-to-last and last values. Default is "and".'
        )
        public String lastDelimiter = 'and';

        @InvocableVariable(
            label = 'Ignore Values'
            description = 'Comma-delimited list of values of fields to exclude from concatenated text. Default is "null, 0".'
        )
        public String ignoreValues = 'null, 0';

    }

    public class Response {

        @InvocableVariable(
            label = 'Concatenated Text'
        )
        public String concatenatedString;

    }

}