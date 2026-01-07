# ECpay Logistics SDK for Ruby

綠界科技物流串接 Ruby SDK（ecpay_logistics）

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Tests](https://github.com/YOUR_USERNAME/ecpay_logistics/workflows/Tests/badge.svg)](https://github.com/YOUR_USERNAME/ecpay_logistics/actions)

本 SDK 提供綠界科技（ECPay）物流服務的 Ruby 介面，支援物流訂單建立、查詢、退貨等完整功能。

原始專案：https://github.com/ECPay/Logistic_RoR

## 版本資訊

- 版本：2.0.0
- Ruby 版本支援：2.7.6, 3.0.7, 3.1.7

## 目錄

- [安裝](#安裝)
- [配置](#配置)
- [主要功能](#主要功能)
  - [建立物流訂單](#1-建立物流訂單-createclient)
  - [查詢物流資訊](#2-查詢物流資訊-queryclient)
  - [退貨處理](#3-退貨處理-returnclient)
  - [C2C 訂單處理](#4-c2c-訂單處理-c2cprocessclient)
- [測試](#測試)
- [支援的物流類型](#支援的物流類型)
- [參考資料](#參考資料)

## 安裝

在 Gemfile 中加入：

```ruby
gem 'ecpay_logistics'
```

然後執行：

```bash
bundle install
```

或直接安裝：

```bash
gem install ecpay_logistics
```

## 配置

在使用前，需要先設定商店資訊。編輯 `conf/logistics_conf.xml`：

```xml
<?xml version="1.0" encoding="utf-8"?>
<Conf>
    <!-- 操作模式：Test（測試）或 Production（正式） -->
    <OperatingMode>Test</OperatingMode>

    <!-- 選擇使用的商店設定檔 -->
    <MercProfile>Stage_Account_Logistics_B2C</MercProfile>

    <!-- 是否為承包商平台：N（否）或 Y（是） -->
    <IsProjectContractor>N</IsProjectContractor>

    <MerchantInfo>
        <!-- 正式環境帳號 -->
        <MInfo name="Production_Account">
            <MerchantID>您的商店代號</MerchantID>
            <HashKey>您的 HashKey</HashKey>
            <HashIV>您的 HashIV</HashIV>
        </MInfo>

        <!-- 測試環境 B2C 帳號 -->
        <MInfo name="Stage_Account_Logistics_B2C">
            <MerchantID>2000132</MerchantID>
            <HashKey>5294y06JbISpM5x9</HashKey>
            <HashIV>v77hoKGq4kWxNNIS</HashIV>
        </MInfo>

        <!-- 測試環境 C2C 帳號 -->
        <MInfo name="Stage_Account_Logistics_C2C">
            <MerchantID>2000933</MerchantID>
            <HashKey>XBERn1YOvpM9nfZc</HashKey>
            <HashIV>h1ONHk4P4yqbl5LK</HashIV>
        </MInfo>
    </MerchantInfo>
</Conf>
```

### 配置說明

- **OperatingMode**: 設定為 `Test`（測試環境）或 `Production`（正式環境）
- **MercProfile**: 指定要使用的商店設定檔名稱
- **IsProjectContractor**: 是否為承包商平台模式
  - `N`: 一般商店模式
  - `Y`: 承包商平台模式（需在 API 呼叫時額外提供 MerchantID）

## 主要功能

### 1. 建立物流訂單 (CreateClient)

用於建立新的物流訂單，支援家配（宅配）和便利店取貨（CVS）。

#### 使用範例

```ruby
require 'ecpay_logistics'

# 建立客戶端
client = ECpayLogistics::CreateClient.new

# 準備訂單參數（CVS 便利店取貨範例）
params = {
  'MerchantTradeNo' => "ORDER#{Time.now.to_i}",           # 商店訂單編號（唯一）
  'MerchantTradeDate' => Time.now.strftime('%Y/%m/%d %H:%M:%S'),
  'LogisticsType' => 'CVS',                                # 物流類型：CVS（便利店）
  'LogisticsSubType' => 'FAMI',                            # 物流子類型：FAMI（全家）
  'GoodsAmount' => 1000,                                   # 商品金額
  'GoodsName' => '測試商品',                                # 商品名稱
  'SenderName' => '寄件人姓名',                             # 寄件人姓名
  'SenderPhone' => '0912345678',                           # 寄件人電話
  'SenderCellPhone' => '0912345678',                       # 寄件人手機
  'ReceiverName' => '收件人姓名',                           # 收件人姓名
  'ReceiverPhone' => '0987654321',                         # 收件人電話
  'ReceiverCellPhone' => '0987654321',                     # 收件人手機
  'ReceiverEmail' => 'receiver@example.com',               # 收件人 Email
  'ReceiverStoreID' => '001779',                           # 收件門市代號
  'ReturnStoreID' => '001779',                             # 退貨門市代號
  'ServerReplyURL' => 'https://your-domain.com/callback'   # 物流狀態通知 URL
}

# 建立訂單
begin
  response = client.create(params)
  puts "訂單建立成功：#{response}"
rescue ECpayErrorDefinition::ECpayError => e
  puts "建立訂單時發生錯誤：#{e.message}"
end
```

#### 家配（宅配）範例

```ruby
params = {
  'MerchantTradeNo' => "ORDER#{Time.now.to_i}",
  'MerchantTradeDate' => Time.now.strftime('%Y/%m/%d %H:%M:%S'),
  'LogisticsType' => 'Home',                               # 物流類型：Home（宅配）
  'LogisticsSubType' => 'TCAT',                            # 宅配子類型：TCAT（黑貓）
  'GoodsAmount' => 1500,
  'GoodsName' => '測試商品',
  'SenderName' => '寄件人姓名',
  'SenderPhone' => '0912345678',
  'SenderCellPhone' => '0912345678',
  'SenderZipCode' => '106',                                # 寄件人郵遞區號
  'SenderAddress' => '台北市大安區某街某號',                 # 寄件人地址
  'ReceiverName' => '收件人姓名',
  'ReceiverPhone' => '0987654321',
  'ReceiverCellPhone' => '0987654321',
  'ReceiverZipCode' => '100',                              # 收件人郵遞區號
  'ReceiverAddress' => '台北市中正區某街某號',               # 收件人地址
  'ReceiverEmail' => 'receiver@example.com',
  'ServerReplyURL' => 'https://your-domain.com/callback'
}

response = client.create(params)
```

### 2. 查詢物流資訊 (QueryClient)

提供多種物流查詢功能。

```ruby
require 'ecpay_logistics'

client = ECpayLogistics::QueryClient.new
```

#### 2.1 電子地圖查詢 (expressmap)

產生便利店電子地圖選擇介面的 HTML 表單。

```ruby
params = {
  'MerchantTradeNo' => "ORDER#{Time.now.to_i}",
  'LogisticsType' => 'CVS',                                # CVS（便利店）
  'LogisticsSubType' => 'FAMI',                            # FAMI（全家）、UNIMART（7-11）、HILIFE（萊爾富）
  'IsCollection' => 'N',                                   # 是否代收貨款：Y/N
  'ServerReplyURL' => 'https://your-domain.com/callback'
}

html_form = client.expressmap(params)
# 回傳 HTML 表單，可直接渲染到頁面讓使用者選擇門市
```

#### 2.2 更新物流資訊 (updateshipmentinfo)

更新物流訂單的寄送資訊。

```ruby
params = {
  'AllPayLogisticsID' => '123456',                         # 綠界物流訂單編號
  'ShipmentNo' => '1234567890',                            # 物流公司貨態編號
  'ReceiverStoreID' => '991182'                            # 更新後的收件門市代號
}

response = client.updateshipmentinfo(params)
```

#### 2.3 查詢物流訂單 (querylogisticstradeinfo)

查詢物流訂單的詳細資訊。

```ruby
params = {
  'AllPayLogisticsID' => '123456'                          # 綠界物流訂單編號
}

response = client.querylogisticstradeinfo(params)
# 回傳物流狀態、貨態等詳細資訊
```

#### 2.4 列印物流單據 (printtradedocument)

產生列印物流單據的表單。

```ruby
params = {
  'AllPayLogisticsID' => '123456',                         # 綠界物流訂單編號
  'LogisticsSubType' => 'FAMI'                             # 物流子類型
}

html_form = client.printtradedocument(params)
```

#### 2.5 物流對帳 (logisticscheckaccounts)

查詢特定日期的物流對帳資訊。

```ruby
params = {
  'PaymentType' => 'FAMI',                                 # 物流子類型
  'StartDate' => '2024/01/01',                             # 開始日期
  'EndDate' => '2024/01/31'                                # 結束日期
}

response = client.logisticscheckaccounts(params)
```

#### 2.6 建立測試資料 (createtestdata)

在測試環境建立測試資料（僅測試環境可用）。

```ruby
params = {
  'LogisticsSubType' => 'FAMI',                            # 物流子類型
  'GoodsAmount' => 1000                                    # 商品金額
}

response = client.createtestdata(params)
```

### 3. 退貨處理 (ReturnClient)

處理物流訂單的退貨申請。

```ruby
require 'ecpay_logistics'

client = ECpayLogistics::ReturnClient.new
```

#### 3.1 家配退貨 (returnhome)

```ruby
params = {
  'AllPayLogisticsID' => '123456',                         # 綠界物流訂單編號
  'ServerReplyURL' => 'https://your-domain.com/callback',
  'SenderName' => '退貨寄件人',
  'SenderPhone' => '0912345678',
  'SenderCellPhone' => '0912345678',
  'SenderZipCode' => '100',
  'SenderAddress' => '台北市中正區某街某號',
  'ReceiverName' => '退貨收件人',
  'ReceiverPhone' => '0987654321',
  'ReceiverCellPhone' => '0987654321',
  'ReceiverZipCode' => '106',
  'ReceiverAddress' => '台北市大安區某街某號'
}

response = client.returnhome(params)
```

#### 3.2 CVS 便利店退貨 (returncvs)

```ruby
params = {
  'AllPayLogisticsID' => '123456',                         # 綠界物流訂單編號
  'ServerReplyURL' => 'https://your-domain.com/callback',
  'SenderName' => '退貨寄件人',
  'SenderPhone' => '0912345678',
  'ReceiverName' => '退貨收件人',
  'ReceiverPhone' => '0987654321',
  'ReceiverStoreID' => '001779'                            # 退貨收件門市代號
}

response = client.returncvs(params)
```

#### 3.3 指定便利店退貨

```ruby
# 萊爾富退貨
response = client.returnhilifecvs(params)

# 7-11 退貨
response = client.returnunimartcvs(params)
```

### 4. C2C 訂單處理 (C2CProcessClient)

處理 C2C（Customer to Customer）物流訂單的相關操作。

```ruby
require 'ecpay_logistics'

client = ECpayLogistics::C2CProcessClient.new
```

#### 4.1 更新門市資訊 (updatestoreinfo)

```ruby
params = {
  'AllPayLogisticsID' => '123456',                         # 綠界物流訂單編號
  'ReceiverStoreID' => '991182',                           # 新的收件門市代號
  'ReturnStoreID' => '991182'                              # 新的退貨門市代號（選填）
}

response = client.updatestoreinfo(params)
```

#### 4.2 取消 C2C 訂單 (cancelc2corder)

```ruby
params = {
  'AllPayLogisticsID' => '123456',                         # 綠界物流訂單編號
  'CVSPaymentNo' => '00001234',                            # 寄貨編號
  'CVSValidationNo' => 'ABCD'                              # 驗證碼
}

response = client.cancelc2corder(params)
```

#### 4.3 列印 C2C 訂單

根據不同便利店列印 C2C 訂單資訊：

```ruby
params = {
  'AllPayLogisticsID' => '123456',                         # 綠界物流訂單編號
  'CVSPaymentNo' => '00001234',                            # 寄貨編號
  'CVSValidationNo' => 'ABCD'                              # 驗證碼
}

# 7-11
html_form = client.printunimartc2corderinfo(params)

# 全家
html_form = client.printfamic2corderinfo(params)

# 萊爾富
html_form = client.printhilifec2corderinfo(params)

# OK 便利店
html_form = client.printokmartc2corderinfo(params)
```

## 測試

本專案包含完整的 RSpec 測試套件，支援多個 Ruby 版本測試。

### 執行測試

#### 單一版本測試

```bash
# 執行所有測試
bundle exec rspec

# 顯示詳細輸出
bundle exec rspec --format documentation

# 執行特定測試文件
bundle exec rspec spec/helper_spec.rb
```

#### 多版本測試

使用 `bin/test_all` 腳本在多個 Ruby 版本上執行測試：

```bash
# 在 Ruby 2.7.6, 3.0.7, 3.1.7 上執行測試
./bin/test_all
```

此腳本會：
- 自動檢查並安裝所需的 Ruby 版本（需要 rbenv）
- 在每個版本上安裝依賴並執行測試
- 顯示詳細的測試結果和摘要

**前置需求：**
- 安裝 [rbenv](https://github.com/rbenv/rbenv)
- 確保腳本有執行權限：`chmod +x bin/test_all`

### 持續整合 (CI)

本專案使用 GitHub Actions 進行自動化測試：

- **多版本測試**：在 Ubuntu 和 macOS 上測試 Ruby 2.7.6, 3.0.7, 3.1.7
- **程式碼品質檢查**：使用 RuboCop 進行代碼檢查
- **自動執行**：每次 push 和 pull request 時自動執行

查看測試狀態：[GitHub Actions](https://github.com/YOUR_USERNAME/ecpay_logistics/actions)

### 測試覆蓋範圍

- ✅ Core Extensions（Hash、String）
- ✅ 錯誤類別
- ✅ API Helper（加密、編碼、HTTP 請求等）
- ✅ CreateClient（訂單建立）

**測試統計：** 63 個測試案例，100% 通過率

詳細測試說明請參閱：[spec/README.md](spec/README.md)

## 支援的物流類型

### 家配（宅配）

| 子類型 | 說明 |
|--------|------|
| TCAT   | 黑貓宅急便 |
| ECAN   | 宅配通 |

### CVS（便利店取貨）

| 子類型 | 說明 |
|--------|------|
| FAMI   | 全家便利商店 |
| UNIMART | 7-ELEVEN |
| HILIFE  | 萊爾富 |

### C2C 物流

| 子類型 | 說明 |
|--------|------|
| FAMIC2C    | 全家店到店 |
| UNIMARTC2C | 7-11 交貨便 |
| HILIFEC2C  | 萊爾富店到店 |
| OKMARTC2C  | OK 便利店店到店 |

## 錯誤處理

SDK 定義了以下錯誤類別：

```ruby
begin
  response = client.create(params)
rescue ECpayErrorDefinition::ECpayInvalidParam => e
  # 參數錯誤
  puts "參數錯誤：#{e.message}"
rescue ECpayErrorDefinition::ECpayLogisticsRuleViolate => e
  # 物流規則違反
  puts "物流規則錯誤：#{e.message}"
rescue ECpayErrorDefinition::ECpayInvalidMode => e
  # 無效的操作模式
  puts "模式錯誤：#{e.message}"
rescue ECpayErrorDefinition::ECpayMissingOption => e
  # 缺少必要選項
  puts "缺少選項：#{e.message}"
rescue ECpayErrorDefinition::ECpayError => e
  # 一般錯誤
  puts "發生錯誤：#{e.message}"
end
```

## 重要事項

1. **測試環境**：建議先在測試環境（`OperatingMode=Test`）完整測試後，再切換到正式環境
2. **訂單編號**：`MerchantTradeNo` 必須是唯一值，建議使用時間戳記或 UUID
3. **回呼網址**：`ServerReplyURL` 必須是可從外部存取的 HTTPS 網址
4. **字元編碼**：所有參數請使用 UTF-8 編碼
5. **安全性**：請妥善保管 HashKey 和 HashIV，不要提交到版本控制系統

## 參考資料

- [官方文件](https://github.com/ECPay/Logistic_RoR/tree/master/Doc)
- [官方範例](https://github.com/ECPay/Logistic_RoR/tree/master/Example/Ruby)
- [綠界科技物流 API 文件](https://developers.ecpay.com.tw/?p=2856)
- [綠界科技開發者中心](https://developers.ecpay.com.tw/)

## 授權

本專案採用 MIT 授權條款。詳見 LICENSE 文件。

## 版本歷史

- 2.0.0 - 當前版本
  - 新增完整測試套件（63 個測試案例，100% 通過率）
  - 支援 Ruby 2.7.6, 3.0.7, 3.1.7 多版本測試
  - 新增 GitHub Actions CI/CD 自動化測試
  - 新增多版本測試腳本 (`bin/test_all`)
  - 新增詳細的 API 使用文件和範例
  - 更新依賴版本相容性
  - 支援多平台（macOS ARM/Intel, Linux）

- 1.0.8 - 前一版本
  - 初始版本

