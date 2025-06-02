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
- **Java + Rust:** Best of both worlds, wired up with JNI.
- **TDD by default:** Test scaffolding included.
- **Pretty, nerdy CLI output:** Color, tables, and more.
- **Extensible:** Add your own helpers and utilities in `scripts/helpers/` and `scripts/utils/`.

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

Run a full system check anytime:

```sh
./scripts/utils/check-system.sh
```

---

## 📦 Upgrade Workflow

Scrutinaut uses the **one job principle** for atomic, robust upgrades:

- **Project scaffolding:**  
  Run `./setup.sh` to generate all directories, scripts, and default code.
- **Java build & test upgrade:**  
  Run `./upgrade-java-pom.sh` to:
  - Overwrite `java_frontend/pom.xml` with your custom Maven build (latest JUnit, fat jar support, etc.)
  - Overwrite `ScrutinautAppTest.java` and other test files with versions compatible with your upgraded dependencies
  - Optionally upgrade other Java files as needed
  - Back up originals before overwriting
  - Show a colorized diff (if `colordiff` is available)
  - Validate the new pom.xml as XML (if `xmllint` is available)

**Custom upgrade assets:**  
Place your custom files in the project root:

- `custom-pom.xml`
- `custom-ScrutinautAppTest.java`
- `custom-UrlInterrogatorTest.java`
- (add more as needed)

---

## 📂 Project Structure

```plaintext
scrutinaut/
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
  └── rust_backend/
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