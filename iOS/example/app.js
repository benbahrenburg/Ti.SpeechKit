var speechKit = require('ti.speechkit');
Ti.API.info("module is => " + speechKit);
var recognize = speechKit.createRecognizer({
	speechKitID:"YOUR_ID_GOES_HERE",
	speechKitHost:"YOUR_HOST_GOES_HERE",
	speechKitPort:443,
	speechKitUseSSL:false
});

var win = Ti.UI.createWindow({
    backgroundColor: 'white',
});

var inputText = Ti.UI.createTextArea({
	backgroundColor:"#999", top:60, bottom:0, width:Ti.UI.FILL, 
	borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED,
});
win.add(inputText);

var recognizeButton = Ti.UI.createButton({
	title:"Tap to run Recognizer", top:10, 
	width:200, height:50, left:5
});
win.add(recognizeButton);

function recognizeCompleted(e){
	Ti.API.info(JSON.stringify(e));
	if(e.success){
		inputText.value = "Recognizer Results:\n" + e.text;
	}else{
		alert(e.message);
	}
};
recognizeButton.addEventListener('click',function(){

	inputText.value = "";
	
	var dialog = Ti.UI.createAlertDialog({
		title:"How it works", buttonNames:["Cancel","Ok"],
		message:"Press ok, then start talking"
	});
	
	dialog.addEventListener("click",function(f){
		if(f.index ===1){
			recognize.startRecording({
				onComplete:recognizeCompleted,
				endDetection : speechKit.SHORT_END_OF_SPEECH,
				recognizerType: speechKit.SEARCH_RECOGNIZER_TYPE
			});			
		}
	});
	dialog.show();	
});


win.addEventListener('open',function(){
	Ti.API.info("Has Microphone permission? " + speechKit.requestPermission());
});
win.open();
