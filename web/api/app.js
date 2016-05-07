var http = require("http"), fs = require("fs"), url = require("url"), path = require("path"), qs = require('querystring'), watson = require('watson-developer-cloud');
var user = "8fbea9f2-4f47-4407-b409-c74fb3ede4ed";
var pass = "ZmyibTmbXSjD";
var toneAnalyzer = watson.tone_analyzer({
    url: 'https://gateway.watsonplatform.net/tone-analyzer-beta/api/',
    username: '8fbea9f2-4f47-4407-b409-c74fb3ede4ed',
    password: 'ZmyibTmbXSjD',
    version_date: '2016-11-02',
    version: 'v3-beta'
});
var server = http.createServer(function (request, response) {
    var url_parts = (request.method == 'GET') ? url.parse(request.url, true) : false;
    if (!!request.url.match("/api")) {
        if (!!request.url.match("bmixtone")) {
            console.log("foo:");
            toneAnalyzer.tone(url_parts.query, function (err, data) {
                //console.log(err,JSON.stringify(data));
                if (!err) {
                    response.writeHead(200, { 'Content-Type': 'application/json' });
                    response.end(JSON.stringify(data));
                }
                else {
                    response.writeHead(400, { 'Content-Type': 'application/json' });
                    response.end(JSON.stringify({ res: "die" }));
                }
            });
        }
    }
    else {
        var Response = {
            "200": function (file, filename) {
                var extname = path.extname(filename);
                var header = {
                    "Access-Control-Allow-Origin": "*",
                    "Pragma": "no-cache",
                    "Cache-Control": "no-cache"
                };
                response.writeHead(200, header);
                response.write(file, "binary");
                response.end();
            },
            "404": function () {
                response.writeHead(404, { "Content-Type": "text/plain" });
                response.write("404 Not Found\n");
                response.end();
            },
            "500": function (err) {
                response.writeHead(500, { "Content-Type": "text/plain" });
                response.write(err + "\n");
                response.end();
            }
        };
        var uri = "../frontend/build/" + url.parse(request.url).pathname, filename = path.join(process.cwd(), uri);
        fs.exists(filename, function (exists) {
            if (!exists) {
                Response["404"]();
                return;
            }
            if (fs.statSync(filename).isDirectory()) {
                filename += '/index.html';
            }
            fs.readFile(filename, "binary", function (err, file) {
                if (err) {
                    Response["500"](err);
                    return;
                }
                Response["200"](file, filename);
            });
        });
    }
}).listen(process.env.VMC_APP_PORT || 3000);
