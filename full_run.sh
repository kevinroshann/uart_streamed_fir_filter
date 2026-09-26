python3 -m venv .venv
source .venv/bin/activate
pip3 install -r requirements.txt 
cd verilog/final_code/
./run.sh
cd signalsending/
python3 serialsend.py 
