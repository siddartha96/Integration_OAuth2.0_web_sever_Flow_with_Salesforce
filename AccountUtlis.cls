public with sharing class AccountUtlis {
    
    public static void createAccount(String name, String rating){

        sal__mdt config = sal__mdt.getInstance(System.Label.Salesforce);// custom lebal name
        if(config!= null){

            Boolean isValid = SalesforceTokenUtil.isValid(config);
            Map<String,Object> fieldWithValuesMap = new Map<String,Object>();
            String accessToken = config.access__c;

            if(!isValid){
                // config.access__c != Token Expired
                // Get the Access token using Refresh Token
                fieldWithValuesMap = SalesforceTokenUtil.refreshToken(config);
                accessToken = (String)fieldWithValuesMap.get('access__c');
            }

            String endpoint = config.instance_url__c+'/services/data/v60.0/sobjects/Account';
            String requestBody = '{'+
		        '    "Name" : "'+name+'",'+
		        '    "Rating" : "'+rating+'",'+
		        '    "Phone" : "7070723402",'+
		        '    "Industry" : "Education",'+
                '   "Active__c" : "Yes"'+
		        '}';

            HttpRequest httpReq =  CalloutUtlis.prepareRequest(endpoint,'POST',requestBody,'application/json','application/json');
            httpReq.setHeader('Authorization','Bearer '+accessToken);

            try{

                HttpResponse httpRes = (new Http()).send(httpReq); 
                if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201){
                    system.debug('ERROR \n'+httpRes.getBody());
                }else{
                    system.debug('ERROR \n'+httpRes.getBody());
                }

            }catch(System.CalloutException ex){
                
                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
             } catch (System.Exception ex){     
            
                // ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            }   

            if(fieldWithValuesMap.size() > 0){
                String fullName = 'sal.'+System.label.Salesforce;
                String label = System.label.Salesforce;

                CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
            }


        }
    }
}