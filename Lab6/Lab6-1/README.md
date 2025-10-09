# Lab 6-1: Design Compiler

## Tool Command Language
### Format
```shell
"command_name" + "variable" + "argument_0" + "argument_1" + ...
```
all variables are in string format
### Example 
```shell
dc_shell> set love 520; # love = "520"
520
dc_shell> echo "love Iclab";
love Iclab
dc_shell> echo "$love Iclab"; # use $ to get variable's value
520 Iclab
dc_shell> set b 37;
37
dc_shell> set a b;
b
dc_shell> echo "a";
a
dc_shell> echo "$a";
b
dc_shell> set c $b;
37
dc_shell> echo "c";
c
dc_shell> echo "$c";
37
dc_shell> set b 8;
8
dc_shell> set a [expr($b+2)];
Error: unknown command 'expr(8+2)' (CMD-005)
dc_shell> set a [expr $b+2]; # use expr to do math operation
10
dc_shell>
```

### Help command
```shell
help "command name";      # 內建說明文件 
man "command name";       # 輔助使⽤說明 
printvar "variable name"; # 輸出變數內容 
echo $"variable name";    # 輸出變數內容
```

## Explore design
| Setting | Original | Without gated clock | With gated clock |
| - | - | - | - |
|Timing | 8.7034|9.3128 | 9.3166|
| Area| 173441| 173727 |149297 |
| Area(alu)| 1967| 2011| 2020|
|Power(Dynamic) |3.7703 |3.78 | 0.786|
|Power(Leakage) | 0.00448| 0.00447| 0.00393|
|Power(Total) | 3.775|3.785 |0.790 |

## .synopsys_dc.setup
### 一、整體背景

.synopsys_dc.setup 會在你打開 dc_shell 時自動被執行。  
它是用來：

- 指定合成要用的資料庫與搜尋路徑（哪裡找 cell library）  
- 設定輸出格式與 reset 判定規則  
- 建立輸出 log 檔與互動介面行為  

整份檔案的邏輯順序可以想成：

| 區段 | 目的 |
|------|------|
| Library 路徑設定 | 告訴 DC 要去哪找 .db、.sdb、.sldb |
| Reset 與 RTL 識別設定 | 告訴 DC 要怎麼處理 reset |
| 輸出環境設定 | 設定 log、編輯器模式、netlist 格式等 |
| 使用介面設定 | 歷史指令、別名等 |

---

### 二、詳細解釋

### ① set search_path "xxxxx"

功能：指定搜尋路徑 (search path)。  
作用：告訴 DC 在找檔案（例如 .v、.db、.lib、.tcl）時，要去哪裡找。  

常見內容：
```
set search_path ". /usr/cadtool/GPDK45/.../db/ $search_path"
```
表示：先在目前目錄（.）找，再去指定資料夾找，最後保留原本的舊路徑。  

關聯：這個變數會被後面的 target_library、link_library 用到。

---

### ② set target_library "yyyyy"

功能：指定綜合時要 map 的 cell library。  
作用：這是「你希望綜合後電路裡的元件」來自哪個 .db 檔。  

例如：
```
set target_library "gsclib045.db"
```
意思是讓 DC 在綜合時使用 GPDK45 標準元件庫（NAND, NOR, INV, DFF…）。

關聯：  
- 它的檔案位置必須包含在 search_path。  
- 綜合後的 gate-level netlist 裡，所有 cell 都要能在這個 library 找到。

---

### ③ set link_library "zzzzz"

功能：指定連結 (link) 時要參考的 library。  
作用：  
在 elaboration 或 link 階段，Design Compiler 會需要知道：  
你 RTL 裡的模組、子模組、或其他 IP 該去哪個 library 找。  

通常會包含：
```
set link_library "* $target_library dw_foundation.sldb"
```
這裡的 * 代表「也包括目前設計內的所有 sub-design」。

關聯：  
- link_library ≈ 「我可參考的所有庫」。  
- target_library ≈ 「我要合成進去的庫」。  
- 它們兩個幾乎總是一起出現。

---

### ④ set symbol_library "?????.sdb"

功能：指定符號庫 (symbol library)。  
作用：給 GUI 工具（如 Design Vision）用，讓電路在 schematic 視窗裡有圖形符號（例如 AND、DFF 的圖示）。  
不影響合成結果，只是讓你能「看懂圖」。

---

### ⑤ set synthetic_library "??????.sldb"

功能：指定高階合成庫 (synthetic library)。  
作用：  
DC 的 DesignWare IP（例如加法器、乘法器、除法器）都不是實體 cell，它們定義在 .sldb 裡。  
當你 RTL 裡寫 a * b、a / b 時，DC 會根據這個 .sldb 去找到對應的 DW 模組實現。  

關聯：  
- synthetic_library 通常會同時加入 link_library 裡。  
- target_library 是標準 cell，synthetic_library 是高階運算模組。

---

### ⑥ set hdlin_ff_always_sync_set_reset true

功能：讓 DC 在 RTL 解析時，把 reset / set 訊號視為同步 (synchronous)。  
作用：  
若不設，DC 有時會把 reset 誤判為組合邏輯，導致電路被化簡或刪除。  

實際效果：  
確保所有 always @(posedge clk or posedge rst) 都正確被翻譯成具 reset pin 的 DFF。

---

### ⑦ set command_log_file "./command.log"
### ⑧ set view_command_log_file "./view_command.log"

功能：指定 log 檔輸出位置。  
作用：  
所有你在 DC 輸入的指令都會被記錄在這兩個 log 裡。  
前者是主要 log，後者可用於 Design Vision 互動環境的操作記錄。

---

### ⑨ set hdlin_translate_off_skip_text "TRUE"

功能：告訴 DC 忽略 RTL 裡被 translate_off/on 包起來的區段。  
範例：
```verilog
// synopsys translate_off
   ... 模擬用的 code ...
// synopsys translate_on
```
作用：這些區塊只是模擬輔助，不該進合成。

---

### ⑩ set edifout_netlist_only "TRUE"

功能：輸出 EDIF 格式 netlist，且只包含 netlist 資訊。  
作用：EDIF 是 EDA 工具間交換用的標準化格式。  
若不用 EDIF，可以輸出 Verilog 格式的 gate-level netlist。

---

### ⑪ set verilogout_no_tri true

功能：在輸出的 Verilog netlist 裡，把 tri-state 腳位改為普通 wire。  
作用：很多 ASIC 流程不允許有 tri-state bus，這個設定可避免產生 tri 型宣告。

---

### ⑫ set sh_enable_line_editing true
### ⑬ set sh_line_editing_mode emacs

功能：設定命令列編輯模式。  
作用：讓你在 DC shell 裡輸入指令時能用方向鍵、刪除、Ctrl+A/E 等快捷鍵。  
emacs 模式只是編輯風格，也可以設 vi。

---

### ⑭ history keep 100

功能：保留最近 100 條指令歷史。  
作用：方便你用上下鍵呼叫以前打過的指令。

---

### ⑮ alias h history

功能：建立別名。  
作用：讓你只要打 h，就等於輸入 history。  
小技巧：這行只是方便操作，不影響合成。

## synthesis.tcl
### 一、檔案總覽  

`synthesis.tcl` 是整個 Design Compiler (DC) 合成流程的主控腳本。  
它不直接進行合成，而是負責：

1. 定義共用變數（如 TOPLEVEL、TEST_CYCLE）  
2. 控制四個分段腳本的執行順序  
3. 確保合成流程標準化、可重複使用  

整個流程以分階段方式組織，如下：  

| 腳本名稱 | 階段功能 | 說明 |
|-----------|-----------|------|
| synthesis.tcl | 主控流程 | 定義參數並呼叫各子腳本 |
| 0_readfile.tcl | 讀取與展開 RTL | 執行 analyze / elaborate / link |
| 1_setting.tcl | 設定環境與時序約束 | 建立 clock、I/O delay、負載等 |
| 2_compile.tcl | 進行實際合成 | 將 RTL 轉換為 gate-level netlist |
| 3_report.tcl | 產生報告與網表輸出 | 匯出 timing、area、power 等報告 |

---

### 二、設計理念  

本腳本遵循「模組化流程控制」原則：  
- **參數集中管理**：將主要變數放在最上層腳本，讓不同設計可共用相同流程。  
- **階段明確劃分**：讀檔、設定、合成、報告各自獨立，方便維護與除錯。  
- **重複利用性高**：換專案時僅需修改 `TOPLEVEL` 與 `TEST_CYCLE`。  

---

### 三、腳本內容與詳細說明  

以下為 `synthesis.tcl` 內容逐行解析。  
### 1️⃣ 重要註解  
說明：  
此行提醒使用者將所有重要參數（如頂層模組名稱、時脈週期等）設定在主腳本中。  
這樣可以讓 0~3 階段的子腳本共用同一份設定，減少重複修改。  

---

### 2️⃣ 設定頂層模組名稱  
`set TOPLEVEL "top_module_name"`
作用：  
設定要合成的頂層模組名稱。  
此變數會在 `0_readfile.tcl` 中被引用，用於 elaboration 階段。  

範例：  
`set TOPLEVEL "fir_top"`
會對應到：
`elaborate $TOPLEVEL -architecture verilog -library $TOPLEVEL`
這樣 DC 會將 `fir_top` 當作主設計進行 elaboration。  

---

### 3️⃣ 設定時脈週期  
作用：  
設定合成目標時脈週期 (clock period)，單位為 ns。  
此變數會在 `1_setting.tcl` 中被使用，產生時脈與 timing constraint。  

範例：  
`create_clock -period $TEST_CYCLE [get_ports clk]`

### 4️⃣ 執行 4 個 sub tcl

## 0_readfile.tcl
創建資料夾來管理所有在 synthesis 的檔案 (log, report, netlist ...)
| 目錄名稱       | 功能                           | 內容範例                                   |
| ---------- | ---------------------------- | -------------------------------------- |
| `$TOP_DIR` | 儲存 elaboration 後的設計資料庫（.ddc） | ./fir_top/fir_top.ddc                  |
| `$RPT_DIR` | 儲存報告檔                        | ./report/area.rpt、timing.rpt、power.rpt |
| `$NET_DIR` | 儲存最終網表                       | ./netlist/fir_top.v                    |

建立變數 TOP_DIR，內容等於 $TOPLEVEL（也就是你設計的頂層模組名稱），讓設計資料輸出資料夾與模組同名。
```shell
set TOP_DIR $TOPLEVEL 
set RPT_DIR report 
set NET_DIR netlist 
sh rm -rf ./$TOP_DIR 
sh rm -rf ./$RPT_DIR 
sh rm -rf ./$NET_DIR 
sh mkdir ./$TOP_DIR 
sh mkdir ./$RPT_DIR 
sh mkdir ./$NET_DIR 
```

---
### 一、disign lib 完整語法

創建⼀個 library 來記錄這個 design
` define_design_lib $TOPLEVEL -path ./$TOPLEVEL`
| 元件                  | 功能                                                 |
| ------------------- | -------------------------------------------------- |
| `define_design_lib` | 指定 Design Compiler 要建立一個新的「設計資料庫」(Design Library)。 |
| `$TOPLEVEL`         | 資料庫名稱（通常與頂層模組名相同）。                                 |
| `-path ./$TOPLEVEL` | 指定該資料庫要儲存的實體資料夾路徑。                                 |

### 二、設計資料庫 (Design Library) 的概念

在 Synopsys Design Compiler 中，每個設計都必須屬於一個 Library。
這個 Library 是 DC 用來存放「設計結構」與「語法分析結果」的資料夾。

簡單來說，它是一個 container，內部會包含：

.syn 檔案（設計資訊）

.mr 檔案（module reference）

.pdb 檔案（parsed database）

這些是 Design Compiler 的中介格式，不同於 Verilog 原始碼或 gate-level netlist。

### 三、解釋
1️⃣ define_design_lib

功能：
建立一個 Design Compiler 的邏輯設計庫 (logical design library)。
這個庫是合成過程中暫存 RTL 與 elaboration 結果的地方。

執行時機：
在執行 analyze 之前一定要先定義。

原因：
因為 analyze 的語法是：

`analyze -format verilog -library <lib_name> {file_list}`


這裡的 <lib_name> 必須是先前用 define_design_lib 定義過的 library 名稱。


