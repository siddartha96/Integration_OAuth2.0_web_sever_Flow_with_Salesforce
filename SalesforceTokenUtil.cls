public with sharing class SalesforceTokenUtil {

    public pageReference getAuthCode(){
        /* custom meta data */

        // https://login.salesforce.com/services/oauth2/authorize?
        //client_id=3MVG9pRzvMkjMb6n55SAtpr6ieztjEs2Iz17TUHULO6JYsDKvXm7ahpa1iifKkC2QUiWdOGZF1s1MQDfijc7u&
        //redirect_uri=https://trailhead.salesforce.com/today&
        //response_type=code

        sal__mdt config = 	sal__mdt.getInstance(System.label.Salesforce);
       
        if(config!=null){

            String orgUrl = config.Environment__c=='Production'? 'https://login.salesforce.com' : 'https://test.salesforce.com';
            system.debug(orgUrl);

            // https://intelogik712-dev-ed--c.develop.vf.force.com/apex/salesforce_token_page?
            String redirect_uri =  System.URL.getOrgDomainURL().toExternalForm()+'/apex/'+config.page__c;
            system.debug(redirect_uri);

            String authorizeUrl = orgUrl+config.auth_url__c+'?client_id='+config.client_id__c+'&redirect_uri='
                 +redirect_uri+'&response_type=code';
            system.debug(authorizeUrl);

            return new pageReference(authorizeUrl);

        } else{
            return null;
        }


    }

    public void getAccessToken(){
        
        // Get the code from Vs page parameter in the apex class.
        String code = ApexPages.currentpage().getParameters().get('code');
        system.debug(code);


        sal__mdt config = 	sal__mdt.getInstance(System.label.Salesforce);
        if(config!=null){

            String orgUrl = config.Environment__c=='Production'? 'https://login.salesforce.com' : 'https://test.salesforce.com';
            String tokenUrl = orgUrl+config.token_url__c;

            String redirect_uri =  System.URL.getOrgDomainURL().toExternalForm()+'/apex/'+config.page__c;

            String requestBody = 'code='+code+'&grant_type=&authorization_code&client_id='
            +config.client_id__c+'&client_secret='+config.client_secret__c+'&redirect_uri='+redirect_uri;
            system.debug(requestBody);


            HttpRequest httpReq = new HttpRequest();
            httpReq.setEndpoint(tokenUrl);
            httpReq.setMethod('POST');
            httpReq.setBody(requestBody);
            httpReq.setHeader('content-type','application/x-www-form-urlencoded');
            httpReq.setHeader('Accept','application/json');
            
            Http htp = new Http();
                try {
                    
                    HttpResponse httpRes = htp.send(httpReq);

                    if(httpRes.getStatusCode() == 200){
                        SalesforceTokenWrapper  wrapper = (SalesforceTokenWrapper) System.Json.deserialize(httpRes.getBody(), SalesforceTokenWrapper.class);

                       // String fullName = 'sal.'+System.label.Salesforce;
                        // String label = System.label.Salesforce;
                        //String label = 'Salesforce Token';

                        String fullName = 'sal.'+System.label.Salesforce;
                        String label = System.label.Salesforce;

                        Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
                        fieldWithValuesMap.put('access__c',wrapper.access_token);
                        fieldWithValuesMap.put('expires_in_time__c',system.now().addHours(2));
                        fieldWithValuesMap.put('instance_url__c',wrapper.instance_url);
                        fieldWithValuesMap.put('long_te__c',wrapper.refresh_token); // refresh token
                        fieldWithValuesMap.put('scope__c',wrapper.scope);
                        fieldWithValuesMap.put('client_id__c',config.client_id__c);
                        fieldWithValuesMap.put('client_secret__c',config.client_secret__c);

                        System.debug('Success \n'+httpRes.getBody());

                        CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Successfull'));


                    }else{
                        System.debug('Error \n'+httpRes.getBody());
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,httpRes.getBody()));
                    }


                } catch (System.CalloutException ex) {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
                } catch(Exception ex){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            }

        }

         
    }

            // how do we know our token got expired or not
        public static Boolean isValid(sal__mdt config){

             Boolean isValid = true;
            
                if(config.expires_in_time__c < system.now()){
                        isValid = false;
                }
                    return isValid;
        }

        public static Map<String,Object> refreshToken(sal__mdt config){

            String orgUrl = config.Environment__c=='Production'? 'https://login.salesforce.com' : 'https://test.salesforce.com';
            String tokenUrl = orgUrl+config.token_url__c;

            String requestBody = 'grant_type=refresh_token&client_id='+config.client_id__c+'&client_secret='
            +config.client_secret__c+'&refresh_token='+config.long_te__c;
            
            system.debug(requestBody);
            HttpRequest httpReq =  CalloutUtlis.prepareRequest(tokenUrl,'POST',requestBody,'application/json','application/x-www-form-urlencoded');

            Map<String,Object> fieldWithValuesMap = new Map<String,Object>();
            try{
                   
                    HttpResponse httpRes = (new Http()).send(httpReq); 
            
                    if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201){
                        SalesforceTokenWrapper  wrapper = (SalesforceTokenWrapper) System.Json.deserialize(httpRes.getBody(), SalesforceTokenWrapper.class);
                        fieldWithValuesMap.put('access__c',wrapper.access_token);
                        fieldWithValuesMap.put('expires_in_time__c',system.now().addHours(2));
                       // CreateUpdateMetadataUtils.createUpdateMetadata(fullName, label, fieldWithValuesMap);
                            
                    } else{
                      
                    }

            } catch(System.CalloutException ex){
                
                
            } catch (System.Exception ex){     
            
                    
            }   

            return fieldWithValuesMap;


            
        }
}