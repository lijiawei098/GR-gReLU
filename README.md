# Augmented Gutenberg-Richter Model with gReLU(x) Functions

This MATLAB program implements parameter fitting for the **augmented Gutenberg-Richter (GR) model** with **gReLU(x)** functions, designed to more accurately capture magnitude completeness and deviations from the standard GR relationship in earthquake catalogs.

## 📌 Features

- Fitting the augmented Gutenberg-Richter model
- Integration of generalized ReLU (gReLU) functions to describe magnitude distribution
- Bootstrap-based statistical evaluation (optional, depending on your extensions)
- Output includes model parameters, diagnostic plots, and complementary cumulative frequency–magnitude distributions (CCFMD)

## 🧑‍💻 Authors

- **Xinyi Wang**  (2979223788@qq.com)
- **Dr. Jiawei Li**  (lijw3@sustech.edu.cn | lijw@pku.edu.cn | lijw@cea-igp.ac.cn)

First version completed in **June 2025**.

## 📂 Structure
project/<br>
├── Functions/ % Core model functions<br>
├── Example/ % Example data<br>
├── Output/ % Output figures and .mat files<br>
├── main.m % Main script to run the model<br>
└── README.md % This file<br>

## 📖 References

If you use this code, please cite or refer to the following studies:

1. Wang, X., <strong>Li, J.</strong><sup>#</sup>, Feng, A., Sornette, D. (2025).
   *Estimating magnitude completeness in earthquake catalogs: A comparative study of catalog-based methods*.
   Journal of Geophysical Research: Solid Earth, 130(9), e2025JB031441. <a href="https://agupubs.onlinelibrary.wiley.com/doi/10.1029/2025JB031441" target="_blank">[Link]</a> <a href="/contents/Papers/2025_JGR_Mc_MS.pdf" target="_blank">[PDF]</a> <a href="/contents/Papers/2025_JGR_Mc_SI.pdf" target="_blank">[SI]</a> <a href="https://github.com/lijiawei098/GR-gReLU" target="_blank">[Code]</a> 


2. Wang, X., Li, J.#, & Sornette, D.# (2025).  
   *Unifying the Gutenberg-Richter Law with Probabilistic Catalog Completeness*. *(in preparation)*.

(\# indicates co-corresponding authors)

## 📬 Contact

For questions, feel free to contact Dr. Jiawei Li or open an issue on GitHub.
