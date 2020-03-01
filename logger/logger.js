// http://vc.mwrta.com/fixedroutetext.html

// Open Google Chrome (does not work in Firefox)
// Go to url
// Open Console (F12)
// Copy/paste all but last line
// Right click > Clear console
// At end of day, Right click > Save as

var uri = 'api/FR/text';
var lastTimes = {}

function printAllLocations(){
    $.getJSON(uri).done(function (data) {
	    var d = new Date();
        $.each(data, function (key, item) {
            if (item) {
				if (item.Route == "Natick Commuter Shuttle") {item.Route = "NCS"}
				if (item.Route == "Mass Bay Riverside Shuttle") {item.Route = "MBRS"}
				if (item.Route == "Mass Bay Campus to Campus Shuttle") {item.Route = "MBCCS"}
				if (item.Route == "MathWorks Express Shuttle") {item.Route = "MWEX"}
				if (item.Route == "Mass Bay Cushing Parking Shuttle") {item.Route = "MBCPS"}
				if (item.Route == "CSBSCS") {item.Route = "BSCS"}
				if (item.Route == "CSFCS") {item.Route = "FCS"}
				
				if (lastTimes[item.VehiclePlate] !== item.DateTime) {
					lastTimes[item.VehiclePlate] = item.DateTime
					var datetime = d.getFullYear() + "-" + (d.getMonth()+1) + "-" + d.getDate() + "T" + d.getHours() + ":" + d.getMinutes() + ":" + d.getSeconds()
					console.log(datetime + " " + item.DateTime + " " + item.Route + " " + item.VehiclePlate + " " + item.Lat + " " + item.Long);
				}
			}
		});
	});
}

var timer = window.setInterval(printAllLocations, 1000);

window.clearInterval(timer)
