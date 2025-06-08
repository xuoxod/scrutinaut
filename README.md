# 🛰️ Scrutinaut

[![Build Status](https://img.shields.io/badge/build-automated-brightgreen)](./setup.sh)
[![Java](https://img.shields.io/badge/Java-17%2B-orange)](https://adoptium.net/)
[![Rust](https://img.shields.io/badge/Rust-1.70%2B-blue)](https://www.rust-lang.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

**Scrutinaut** is a next-gen, TDD-first, console-based web interrogation toolkit—powered by a Java frontend and a Rust backend.  
It’s designed for lazy, modern developers who want to get straight to coding, not scaffolding.

---

## 🚀 Features

- **One-command setup:** `./setup.sh` builds everything for you.
- **Atomic upgrades:** `./upgrade-java-pom.sh` upgrades your Java build and tests in one go.
- **Java + Rust:** Best of both worlds, wired up with CLI integration.
- **TDD by default:** Test scaffolding included.
- **Pretty, nerdy CLI output:** Color, tables, and more.
- **Extensible:** Add your own helpers and utilities in `scripts/helpers/` and `scripts/utils/`.
- **Cross-platform:** Windows batch launcher included.
- **Configurable:** Use a `.env` file for custom environment variables.

---

## 🛠️ Quickstart

```sh
git clone https://github.com/xuoxod/scrutinaut.git
cd scrutinaut
./setup.sh
./upgrade-java-pom.sh   # <--- Upgrade Java build and tests after setup
```

---

## 🌱 Branching

For experimental or enhanced setup and automation, use the branch:

```sh
git checkout -b neonaut
```

This branch is dedicated to advanced setup, automation, and CLI experience improvements.

---

## 🧪 System Requirements

- Java 17+ (`java`, `javac`)
- Rust 1.70+ (`rustc`, `cargo`)
- Maven 3.6+
- (Optional) VS Code, tree, figlet, lolcat, toilet
- (For some tests) Python 3 (`python3`)

Run a full system check anytime:

```sh
./scripts/utils/check-system.sh
```

---

## 📦 Build & Distribution

**To build everything for end-users:**

1. **Build the Rust backend:**

    ```sh
    cd rust_backend
    cargo build --release
    cd ..
    ```

2. **Build the Java frontend and package the Rust binary:**

    ```sh
    cd java_frontend
    mvn clean package
    ```

    This will:
    - Build a fat JAR (`scrutinaut-app-1.0-SNAPSHOT-jar-with-dependencies.jar`)
    - Copy the Rust binary (`url_scraper_cli`) into the `target/` directory
    - Create a distributable zip (`scrutinaut-app-1.0-SNAPSHOT-dist.zip`) with both files

3. **Distribute the contents of `java_frontend/target/`** (or the zip) to end-users.

---

## 🖥️ End-User Usage

**On Linux/macOS:**

```sh
unzip scrutinaut-app-1.0-SNAPSHOT-dist.zip
cd target
java -jar scrutinaut-app-1.0-SNAPSHOT-jar-with-dependencies.jar scrape https://www.rust-lang.org/
```

**On Windows:**

- Use the batch launcher:
  ```
  java_frontend\launch-scrutinaut.bat scrape https://www.rust-lang.org/
  ```
  (Or double-click `launch-scrutinaut.bat` and enter your arguments.)

---

## ⚙️ Configuration

- Copy `.env.example` to `.env` in the project root to customize environment variables.
- Example:
  ```dotenv
  # .env
  SCRUTINAUT_RUST_CLI=./url_scraper_cli
  JAVA_OPTS=-Xmx512m
  ```

---

## 🧪 Running Tests

- **Standard tests:**  

  ```sh
  mvn test
  ```

- **To run a specific test class:**  

  ```sh
  mvn -Dtest=com.gmail.xuoxod.scrutinaut.ScrutinautAppTest test
  ```

- **NetworkUtilsTest requires a local HTTP server.**  
  Before running this test, start a local server in the project root (or where your test HTML file is located):

  ```sh
  python3 -m http.server 8080
  ```

  Then run your tests as usual.

---

## 📂 Project Structure

```plaintext
scrutinaut/
  ├── .env.example
  ├── setup.sh
  ├── upgrade-java-pom.sh
  ├── custom-pom.xml
  ├── custom-ScrutinautAppTest.java
  ├── custom-UrlInterrogatorTest.java
  ├── README.md
  ├── .gitignore
  ├── scripts/
  │   ├── 01-setup-rust-backend.sh
  │   ├── 02-setup-java-frontend.sh
  │   ├── 03-setup-jni-bridge.sh
  │   ├── inspect-scrutinaut.sh
  │   ├── helpers/
  │   └── utils/
  │       └── check-system.sh
  ├── java_frontend/
  │   ├── pom.xml
  │   ├── launch-scrutinaut.bat
  │   ├── src/
  │   │   ├── main/
  │   │   └── test/
  │   └── target/
  │       ├── scrutinaut-app-1.0-SNAPSHOT-jar-with-dependencies.jar
  │       ├── url_scraper_cli
  │       └── scrutinaut-app-1.0-SNAPSHOT-dist.zip
  └── rust_backend/
      ├── Cargo.toml
      ├── src/
      └── target/
```

---

## 🤖 Philosophy

- **Automate everything:** Developers should focus on logic, not boilerplate.
- **Transparency:** All setup steps and checks are visible and color-coded.
- **Atomic upgrades:** Each script does one job, and does it well.
- **Nerdy by design:** ASCII banners, color output, and a technical, fun vibe.

---

## 📝 License

MIT License. See [LICENSE](LICENSE) for details.

---

### **Built with 🚀, ☕, 🦀, and ❤️ by emhcet & contributors**