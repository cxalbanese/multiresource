({
	 onCheck: function(cmp, evt) {
         cmp.set("v.dow","");
         var i;
         var tstring=[];
		 for (i = 0; i < 7; i++) {
		  tstring[i] = "";
			}
		 var iday0 = cmp.find("iday0").get("v.value");
		 var iday1 = cmp.find("iday1").get("v.value");
		 var iday2 = cmp.find("iday2").get("v.value");
		 var iday3 = cmp.find("iday3").get("v.value");
		 var iday4 = cmp.find("iday4").get("v.value");
		 var iday5 = cmp.find("iday5").get("v.value");
		 var iday6 = cmp.find("iday6").get("v.value");         
         var istart0 = cmp.find("istart0").get("v.value");         
         var istart1 = cmp.find("istart1").get("v.value");
         var istart2 = cmp.find("istart2").get("v.value");
         var istart3 = cmp.find("istart3").get("v.value");
         var istart4 = cmp.find("istart4").get("v.value");
         var istart5 = cmp.find("istart5").get("v.value");
         var istart6 = cmp.find("istart6").get("v.value");
         if(iday0) {cmp.set("v.dow","Sunday");cmp.set("v.thestring[0]",istart0);}
         if(iday1) {cmp.set("v.dow", cmp.get("v.dow")+",Monday");cmp.set("v.thestring[1]",istart1);}
         if(iday2) {cmp.set("v.dow", cmp.get("v.dow")+",Tuesday");cmp.set("v.thestring[2]",istart2);}
         if(iday3) {cmp.set("v.dow", cmp.get("v.dow")+",Wednesday");cmp.set("v.thestring[3]",istart3);}
         if(iday4) {cmp.set("v.dow", cmp.get("v.dow")+",Thursday");cmp.set("v.thestring[4]",istart4);}
         if(iday5) {cmp.set("v.dow", cmp.get("v.dow")+",Friday");cmp.set("v.thestring[5]",istart5);}
         if(iday6) {cmp.set("v.dow", cmp.get("v.dow")+",Saturday");cmp.set("v.thestring[6]",istart6);} 
	 }
})