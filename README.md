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
```

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

## 📂 Project Structure

```plaintext
scrutinaut/
  ├── setup.sh
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
- **Nerdy by design:** ASCII banners, color output, and a technical, fun vibe.

---

## 📝 License

MIT License. See [LICENSE](LICENSE) for details.

---

### **Built with 🚀, ☕, 🦀, and ❤️ by emhcet & contributors**