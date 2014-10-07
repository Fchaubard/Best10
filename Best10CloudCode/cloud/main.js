
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("verifyPhoneNumber", function(request, response) {
  //response.success("Hello world!");
  console.log(request.params);
  console.log("Received a new text: " + request.params.From);
  console.log("Received a new body: " + request.params.Body);


  var query = new Parse.Query("VerificationCode");
  query.equalTo("verifCode", request.params.Body);
  query.find({
    success: function(results) {
    	if (!(results.length > 1)) {
    		// save the number to the verif code record...
      		console.log("good! Saving number to verifCode");
      		results[0].set("number",request.params.From);
      		results[0].save();
	     
      	  //results[0].set("number","-1"); // error code is -1
      	  //results[0].save();
      	  response.success("successfully added number to field!!");
      	}else{
      	  response.error("more than 1 verifCode.. should be unique");
	      console.log("too many matches");
      	}

    },
    error: function() {
      response.error("some error!");
      console.log("some error!");
   
    }
  });

  //response.success();
});
