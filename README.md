# Augmented Gutenberg–Richter Model Fitting Functions (MATLAB)

本仓库当前包含 4 个**自包含**的 MATLAB 函数，用于地震目录震级数据的增强 Gutenberg–Richter（GR）模型参数反演，并通过 bootstrap 估计参数不确定性。

## Included Functions

- `Functions/GR_AE.m`：GR_AE 模型（5 参数）
- `Functions/GR_BS.m`：GR_BS / BSReLU 模型（5 参数）
- `Functions/GR_CO.m`：GR_CO / CoReLU 模型（4 参数）
- `Functions/GR_SS.m`：GR_SS / SSReLU 模型（4 参数）

---

## 1. Input/Output Convention

### Input
所有函数输入一致：

```matlab
Magnitude   % N×1 或 1×N 的震级向量
```

- 函数会自动转为列向量并过滤非有限值。
- 若有效样本数 `< 30`，函数会报错。

### Output
所有函数输出统一为结构体 `Parameters`，典型字段：

- `.names`：参数名称
- `.estimate`：全样本拟合点估计
- `.std`：bootstrap 标准差
- `.ci95`：95% 百分位置信区间
- `.bounds`：拟合时参数上下界
- `.bootstrap`：成功的 bootstrap 参数样本
- `.n_bootstrap`：成功 bootstrap 次数

> 当前四个函数都设置 `n_boot = 200`。

---

## 2. Function Details

### 2.1 `GR_AE`

```matlab
Parameters = GR_AE(Magnitude)
```

- 参数：`a, b, mc, sigma_mc, theta`
- 适用于 AE 形式增强 GR 模型。

### 2.2 `GR_BS`

```matlab
Parameters = GR_BS(Magnitude)
```

- 参数：`a, b, mc, sigma_mc, C`
- 其中 `C` 为 BSReLU 中的平移参数。

### 2.3 `GR_CO`

```matlab
Parameters = GR_CO(Magnitude)
```

- 参数：`a, b, mc, sigma_mc`
- CoReLU 形式（无 `theta` 参数）。

### 2.4 `GR_SS`

```matlab
Parameters = GR_SS(Magnitude)
```

- 参数：`a, b, mc, sigma_mc`
- SSReLU 形式（无 `theta` 参数）。

---

## 3. Minimal Usage Example

```matlab
% Example magnitude vector
Magnitude = [2.1; 2.3; 2.0; 2.8; 3.1; 2.5; 3.0; 2.7; 3.2; 2.4; ...
             2.6; 2.9; 3.3; 2.2; 3.0; 2.8; 3.1; 2.7; 2.5; 3.4; ...
             2.6; 2.8; 3.0; 3.2; 2.9; 2.7; 3.1; 2.5; 2.4; 3.3];

P_AE = GR_AE(Magnitude);
P_BS = GR_BS(Magnitude);
P_CO = GR_CO(Magnitude);
P_SS = GR_SS(Magnitude);

disp(P_AE.estimate)
disp(P_BS.estimate)
disp(P_CO.estimate)
disp(P_SS.estimate)
```

---

## 4. Algorithm Notes

每个函数都采用以下流程：

1. 计算 CCFMD/FMD（内部 `local_Cal_fmd`）。
2. 用 max-curvature 初始化 `mc`（内部 `local_maxc`）。
3. 在参数边界内做加权非线性最小二乘（`lsqnonlin` + multistart）。
4. 对 `Magnitude` 做 bootstrap 重采样（200 次）估计不确定性。

---

## 5. Dependencies

- MATLAB
- Optimization Toolbox（需要 `lsqnonlin`）
- Statistics and Machine Learning Toolbox（`GR_BS` 里使用 `normcdf`）

---

## 6. References

1. Wang, X., Li, J., Feng, A., Sornette, D. (2025). *Estimating magnitude completeness in earthquake catalogs: A comparative study of catalog-based methods*. Journal of Geophysical Research: Solid Earth, 130(9), e2025JB031441.
2. Li, J., Wang, X., Sornette, D. (2026). *Unifying the Gutenberg-Richter law with probabilistic catalog completeness*. Seismological Research Letters (to be published) or https://doi.org/10.48550/arXiv.2506.16849.

---

Dr. Jiawei Li & Ms. Xinyi Wang  
README updated by Codex assistant.
