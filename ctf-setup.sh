#!/usr/bin/env bash
# CTF toolbox setup cho Ubuntu 24.04 (VM local hoặc VPS)
# Mảng: Crypto, AI/IoT, Forensics
# Chạy: chmod +x ctf-setup.sh && ./ctf-setup.sh
set -euo pipefail

# Tránh các hộp thoại tương tác (wireshark, tzdata, ...)
APT="sudo DEBIAN_FRONTEND=noninteractive apt-get"

echo "[*] Cập nhật hệ thống..."
$APT update && $APT -y upgrade

echo "[*] Công cụ nền tảng..."
$APT install -y build-essential git curl wget unzip p7zip-full \
  python3 python3-pip python3-venv pipx tmux vim jq file xxd \
  gdb gdb-multiarch radare2 docker.io
sudo usermod -aG docker "$USER"

echo "[*] Forensics..."
$APT install -y \
  sleuthkit autopsy foremost testdisk scalpel libimage-exiftool-perl \
  binwalk steghide pngcheck tshark wireshark ruby-full hashcat john
sudo gem install zsteg
# stegseek (brute force steghide nhanh)
{ wget -q https://github.com/RickdeJager/stegseek/releases/download/v0.6/stegseek_0.6-1.deb -O /tmp/stegseek.deb \
  && $APT install -y /tmp/stegseek.deb; } || echo "[!] Bỏ qua stegseek"

echo "[*] IoT / firmware..."
$APT install -y qemu-user-static qemu-system-arm qemu-system-mips \
  squashfs-tools mtd-utils mosquitto-clients openjdk-21-jdk
# Ghidra: tải bản mới nhất thủ công tại https://github.com/NationalSecurityAgency/ghidra/releases

echo "[*] Python venv cho CTF..."
python3 -m venv ~/ctf-venv
# shellcheck disable=SC1090
source ~/ctf-venv/bin/activate
pip install --upgrade pip
# Crypto
pip install pycryptodome gmpy2 sympy z3-solver pwntools ecdsa
# Forensics
pip install volatility3 scapy pyshark
# AI (bản CPU, nhẹ; đổi sang bản CUDA nếu VM có GPU)
pip install torch --index-url https://download.pytorch.org/whl/cpu
pip install numpy pandas scikit-learn transformers jupyterlab pillow
deactivate

echo "[*] RsaCtfTool..."
mkdir -p ~/tools
git clone --depth 1 https://github.com/RsaCtfTool/RsaCtfTool ~/tools/RsaCtfTool || true

echo "[*] SageMath qua Docker (tránh cài nặng)..."
sudo docker pull sagemath/sagemath:latest || echo "[!] Kéo lại sau khi đăng nhập lại (quyền docker)"

cat <<'MSG'

[+] Xong!
  - Kích hoạt môi trường Python:  source ~/ctf-venv/bin/activate
  - Chạy Sage:  docker run -it -v "$PWD":/home/sage/work sagemath/sagemath
  - Đăng xuất / đăng nhập lại để dùng docker không cần sudo.
MSG
