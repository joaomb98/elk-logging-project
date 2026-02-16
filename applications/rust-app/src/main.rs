use std::env;
use std::io::Write;
use std::net::TcpStream;
use std::thread;
use std::time::Duration;
use serde_json::json;
use chrono::Utc;
use rand::Rng;

fn main() {
    let logstash_host = env::var("LOGSTASH_HOST").unwrap_or_else(|_| "logstash".to_string());
    let logstash_port = env::var("LOGSTASH_PORT").unwrap_or_else(|_| "5000".to_string());
    let app_name = env::var("APP_NAME").unwrap_or_else(|_| "rust-app".to_string());
    let environment = env::var("ENVIRONMENT").unwrap_or_else(|_| "development".to_string());
    let hostname = hostname::get()
        .unwrap_or_else(|_| "unknown".into())
        .to_string_lossy()
        .to_string();

    println!("Rust application started - connecting to Logstash at {}:{}", logstash_host, logstash_port);

    let mut counter = 0;
    let mut rng = rand::thread_rng();

    loop {
        counter += 1;

        let (level, message) = match counter % 5 {
            0 => ("DEBUG", format!("Debug message #{}: Application state check", counter)),
            1 => ("INFO", format!("Info message #{}: Processing request", counter)),
            2 => ("WARNING", format!("Warning message #{}: Resource usage at 75%", counter)),
            3 => ("ERROR", format!("Error message #{}: Failed to connect to database", counter)),
            4 => ("CRITICAL", format!("Critical message #{}: System failure detected!", counter)),
            _ => ("INFO", format!("Log message #{}", counter)),
        };

        send_log(
            &logstash_host,
            &logstash_port,
            &app_name,
            &environment,
            &hostname,
            level,
            &message,
        );

        let sleep_time = rng.gen_range(2..5);
        thread::sleep(Duration::from_secs(sleep_time));
    }
}

fn send_log(
    host: &str,
    port: &str,
    app_name: &str,
    environment: &str,
    hostname: &str,
    level: &str,
    message: &str,
) {
    let log_entry = json!({
        "timestamp": Utc::now().to_rfc3339(),
        "level": level,
        "message": message,
        "app_name": app_name,
        "environment": environment,
        "hostname": hostname,
        "logger": "rust-logger"
    });

    let json_log = log_entry.to_string();
    
    // Print to console
    println!("{}", json_log);

    // Send to Logstash via TCP
    let address = format!("{}:{}", host, port);
    match TcpStream::connect(&address) {
        Ok(mut stream) => {
            let data = format!("{}\n", json_log);
            if let Err(e) = stream.write_all(data.as_bytes()) {
                eprintln!("Error sending log: {}", e);
            }
        }
        Err(e) => {
            eprintln!("Error connecting to Logstash: {}", e);
        }
    }
}
