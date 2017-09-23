var http = require('http'),
    https = require('https'),
    EventEmitter = require('events').EventEmitter,
    inherits = require('util').inherits,
    extend = require('util')._extend,
    fs = require('fs'),
    path = require('path'),
    favicon = require('serve-favicon'),
    WebSocketServer = require('ws').Server,
    Session = require('./session'),
    buildUrl = require('../index.js').buildInspectorUrl,
    OVERRIDES = path.join(__dirname, '../front-end-node'),
    WEBROOT = path.join(__dirname, '../front-end'),
    daemonConfig = new require(__dirname+'/../../daemonConfig')(__dirname+'/../../../config.json');

function debugAction(req, res) {
  if (!req.query.ws) {
    var newUrl = this.address().url;
    return res.redirect(newUrl);
  }
  res.sendFile(path.join(WEBROOT, 'inspector.html'));
}

function inspectorJson(req, res) {
  res.sendFile(path.join(OVERRIDES, 'inspector.json'));
}

function handleWebSocketConnection(socket) {
  var debugPort = this._getDebuggerPort(socket.upgradeReq.url);
  this._createSession(debugPort, socket);
}

function handleServerListening() {
  this.emit('listening');
}

function handleServerError(err) {
  if (err._handledByInspector) return;
  err._handledByInspector = true;
  this.emit('error', err);
}

function DebugServer() {}

inherits(DebugServer, EventEmitter);

DebugServer.prototype.start = function(options) {
  this._config = extend({}, options);
  this._isHTTPS = this._config.sslKey && this._config.sslCert ? true : false;

  this.wsServer = new WebSocketServer({
    host:'localhost',
    port: this._config.webPort,
    verifyClient:daemonConfig.ipWhitelist
  });
  this.wsServer.on('connection', handleWebSocketConnection.bind(this));
  this.wsServer.on('error', handleServerError.bind(this));
};

DebugServer.prototype._getDebuggerPort = function(url) {
  return parseInt((/[\?\&]port=(\d+)/.exec(url) || [null, this._config.debugPort])[1], 10);
};

DebugServer.prototype._createSession = function(debugPort, wsConnection) {
  return new Session(this._config, debugPort, wsConnection);
};

DebugServer.prototype.close = function() {
  if (this.wsServer) {
    this.wsServer.close();
    this.emit('close');
  }
};

DebugServer.prototype.address = function() {
  var address = 'n/a';
  var config = this._config;
  address.url = buildUrl(config.webHost, address.port, config.debugPort, null, this._isHTTPS);
  return address;
};

exports.DebugServer = DebugServer;
