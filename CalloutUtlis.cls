public with sharing class CalloutUtlis {
   
    public static HttpRequest prepareRequest(String endpoint, String method, String body,string accept,String contentType){

        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(endpoint);
        httpReq.setMethod(method);
       
        httpReq.setHeader('content-type',contentType);
        
        if(!string.isBlank(accept)){
            httpReq.setHeader('Accept',accept);
        }

        if(!string.isBlank(body)){
            httpReq.setBody(body);
        }

       return httpReq;

    }

}