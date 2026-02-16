const net = require('net');
const os = require('os');

const logstashHost = process.env.LOGSTASH_HOST || 'logstash';
const logstashPort = parseInt(process.env.LOGSTASH_PORT) || 5000;
const appName = process.env.APP_NAME || 'nodejs-app';
const environment = process.env.ENVIRONMENT || 'development';
const hostname = os.hostname();

console.log(`Node.js application started - connecting to Logstash at ${logstashHost}:${logstashPort}`);

let counter = 0;

function sendLog(level, message) {
    const logEntry = {
        timestamp: new Date().toISOString(),
        level: level,
        message: message,
        app_name: appName,
        environment: environment,
        hostname: hostname,
        logger: 'nodejs-logger'
    };

    const jsonLog = JSON.stringify(logEntry);
    
    // Print to console
    console.log(jsonLog);

    // Send to Logstash via TCP
    const client = new net.Socket();
    
    client.connect(logstashPort, logstashHost, () => {
        client.write(jsonLog + '\n');
        client.destroy();
    });

    client.on('error', (err) => {
        console.error('Error sending log:', err.message);
    });
}

function generateLogs() {
    counter++;
    
    let level, message;
    
    switch (counter % 5) {
        case 0:
            level = 'DEBUG';
            message = `Debug message #${counter}: Application state check`;
            break;
        case 1:
            level = 'INFO';
            message = `Info message #${counter}: Processing request`;
            break;
        case 2:
            level = 'WARNING';
            message = `Warning message #${counter}: Resource usage at 75%`;
            break;
        case 3:
            level = 'ERROR';
            message = `Error message #${counter}: Failed to connect to database`;
            break;
        case 4:
            level = 'CRITICAL';
            message = `Critical message #${counter}: System failure detected!`;
            break;
    }

    sendLog(level, message);
    
    // Random sleep between 2-5 seconds
    const sleepTime = Math.floor(Math.random() * 3000) + 2000;
    setTimeout(generateLogs, sleepTime);
}

// Start generating logs
generateLogs();
