# ECpay Logistics Gem 測試文件

此目錄包含了 ECpay Logistics gem 的測試套件。

## 測試框架

- RSpec 3.x

## 執行測試

```bash
# 執行所有測試
bundle exec rspec

# 執行特定測試文件
bundle exec rspec spec/helper_spec.rb

# 顯示詳細輸出
bundle exec rspec --format documentation
```

## 測試覆蓋範圍

### Core Extensions (`spec/core_ext/`)

#### `hash_spec.rb`
測試 Hash 的 `stringify_keys` 方法：
- 將 Symbol 鍵轉換為 String 鍵
- 保留原有的 String 鍵
- 處理混合鍵值
- 檢測重複鍵名錯誤
- 處理嵌套 Hash

#### `string_spec.rb`
測試 String 的 `hashify` 方法：
- 將 URL 編碼字符串轉換為 Hash
- 處理 URL 編碼值
- 處理空值
- 支援中文字符（UTF-8）
- 處理特殊字符

### Error Classes (`spec/error_spec.rb`)

測試所有自定義錯誤類：
- `ECpayError` - 基礎錯誤類
- `ECpayMissingOption` - 缺少選項錯誤
- `ECpayInvalidMode` - 無效模式錯誤
- `ECpayInvalidParam` - 無效參數錯誤
- `ECpayLogisticsRuleViolate` - 物流規則違反錯誤

### API Helper (`spec/helper_spec.rb`)

測試 `APIHelper` 類的核心功能：

#### 基本方法
- `get_mercid()` - 獲取商人 ID
- `get_merc_tra_date()` - 獲取交易日期
- `get_op_mode()` - 獲取操作模式（Test/Production）
- `get_curr_unixtime()` - 獲取當前 Unix 時間戳
- `is_contractor?()` - 檢查是否為承包商模式

#### URL 編碼
- `urlencode_dot_net()` - .NET 兼容的 URL 編碼
  - 支援不同的大小寫轉換（UP/DOWN/KEEP）
  - 正確處理 .NET 特殊字符（!*()）
  - 處理中文等多位元組字符

#### 參數處理
- `encode_special_param!()` - 編碼特殊參數
  - 選擇性編碼指定的參數
  - 不影響未指定的參數

#### 校驗碼生成
- `gen_chk_mac_value()` - 生成校驗碼
  - 支援 MD5（mode: 0）和 SHA256（mode: 1）
  - 拒絕包含敏感鍵的參數（CheckMacValue, HashKey, HashIV）
  - 對相同參數產生一致的校驗碼
  - 對不同參數產生不同的校驗碼

#### HTTP 請求
- `http_request()` - 發送 HTTP 請求
  - 僅支援 GET 和 POST 方法

### Create Client (`spec/create_client_spec.rb`)

測試 `CreateClient` 類的物流訂單創建功能：

#### 初始化
- 正確創建實例
- 初始化 Helper
- 包含錯誤定義模組

#### 參數驗證
- 拒絕非 Hash 類型的參數（String, Array, nil）
- 將 Symbol 鍵轉換為 String 鍵
- 驗證必填欄位

#### 承包商模式
- 當為承包商時，要求指定 MerchantID
- 當不是承包商時，自動設定 MerchantID
- 正確設定 PlatformID

#### 參數處理流程
- 參數轉換
- 特殊參數編碼
- 校驗碼生成
- HTTP 請求發送

## 測試統計

- 總測試數：63 個
- 測試通過率：100%

## 注意事項

1. 某些測試使用 mocking 來避免實際的 HTTP 請求
2. Helper 類的測試需要有效的 `conf/logistics_conf.xml` 配置文件
3. 測試使用隨機順序執行以確保測試之間沒有依賴關係

## 待擴充的測試

未來可以考慮添加以下測試：

1. `QueryClient` - 物流查詢功能測試
2. `ReturnClient` - 退貨功能測試
3. `C2CProcessClient` - C2C 處理功能測試
4. 驗證類的完整測試（`CreateParamVerify`, `QueryParamVerify` 等）
5. 整合測試（需要測試環境的 API 端點）
6. 更多邊界情況和錯誤處理測試
