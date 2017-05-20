---
  title: 'STAT/CSSS 564: Assignment 4'
author: Miranda Petty
output:
  html_document: default
date: "May 14, 2017"
---
  
  ## Instructions
  
  1. Fork this repository to your account
2. Edit the file `solutions.Rmd` with your solutions to the problems.
3. Submit a pull request to have it graded. Include an up-to-date knitted HTML or PDF file.

For updates and questions follow the Slack channel: [#assignment4](https://uwcsss564.slack.com/messages/C5DBV8266).
  
  This assignment will require the following R packages:
    ```{r, message=FALSE}
  library("rstan")
  library("rstanarm")
  ```
  
  And you might as well use all your cores:
    ```{r}
  rstan_options(auto_write = TRUE)
  options(mc.cores = parallel::detectCores())
  ```
  
  ## Problem 1 Replicating Fearon
  
  ```{r, message=FALSE}
  library("rstan")
  library("rstanarm")
  library("foreign")
  library("tidyverse")
  library("loo")
  ```
  
  Set these for fast sampling
  ```{r}
  rstan_options(auto_write = TRUE)
  options(mc.cores = parallel::detectCores())
  ```
  
  
  @FearonLaitin2003 is a famous paper in the civil war (intra-state) war literature.
  It analyzes the factors associated with the onset of civil war 
  
  
  @MontgomeryNyhan2010a replicate this work using Bayesian Model Averaging.
  We will replicate it using regularization methods. 
  Replication data is [here](http://www.dartmouth.edu/~nyhan/montgomery-nyhan-replication.zip).
  
  ```{r}
  wars <- read_dta('data/nwarsl.dta')
  other <- read.dta('data/fl.dta')
  df <- inner_join(wars, other, by = c('ccode', 'year'))
  df <- df[df$onset != 4,]  # coding error
  df$loglang <- log(df$numlang)
  keepvars <- "onset warl gdpenl lpopl1 lmtnest ncontig Oil nwstate instab polity2l ethfrac relfrac anocl deml nwarsl plural plurrel muslim loglang colfra eeurop lamerica ssafrica asia nafrme second"
  keepvars <- strsplit(keepvars, split = " ")[[1]]
  df <- df[,keepvars]
  ```
  
  Estimate the two models that BMA uses in the paper (with weakly informative priors), and calculate the LOO performance of these methods. When replicating results from papers, you will often have to dig through some confusing code or files, perhaps in programming languages or file formats you're unfamiliar with (we had to do this to write this question!). The two logit models are the first and third used by Fearon and Laitin, and they are specified in the `f&l-rep.do` file in the reference-code directory, which is a Stata file. It shouldn't be too hard to figure out the model specification from this file, but Slack message one of us if you need a hint.
  
  $$
    \begin{aligned}[t]
  \beta_0 &\sim N(0, 5) \\
  \beta_k &\sim N(0, 2.5) & \text{for $k \in 1, \dots, K$.}
  \end{aligned} 
  $$
    
    ```{r}
  #I pulled the following models from the f&l-rep.do file
  mod <- stan_glm(onset ~ warl + gdpenl + lpopl1 + lmtnest + ncontig + Oil + nwstate + instab + polity2l + ethfrac + relfrac, family = binomial(), data = df, prior = normal(0,5))
  loo_mod <- loo(mod)
  mod2 <- stan_glm(onset ~ warl + gdpenl + lpopl1 + lmtnest + ncontig + Oil + nwstate + instab + ethfrac + relfrac + anocl + deml, family = binomial(), data = df, prior = normal(0,2.5))
  loo_mod2 <- loo(mod2)
  compare(loo_mod, loo_mod2)
  ```
  ## Problem 2 Regularization Priors
  Now estimate this model with all 25 predictor variables and the following priors
  
  1. Weakly informative (as above)
  2. Hierarchical Shrinkage (df = 3)
  
  ```{r}
  mod3 <- stan_glm(onset ~ warl + gdpenl + lpopl1 + lmtnest + ncontig + Oil + nwstate + instab + polity2l + ethfrac + relfrac + anocl + deml + nwarsl + plural + plurrel + muslim + loglang + colfra + eeurop + lamerica + ssafrica + asia + nafrme + second, family = binomial(), data = df)
  loo_mod1 <- loo(mod3)
  
  #the hierarchal model takes a VERY long time to run! 
  mod4 <- stan_glm(onset ~ warl + gdpenl + lpopl1 + lmtnest + ncontig + Oil + nwstate + instab + polity2l + ethfrac + relfrac + anocl + deml + nwarsl + plural + plurrel + muslim + loglang + colfra + eeurop + lamerica + ssafrica + asia + nafrme + second, family = binomial(), data = df, prior = hs(df = 3), adapt_delta = .9999999)
  loo_mod2 <- loo(mod4)
  
  compare(loo_mod1, loo_mod2)
  ```
  
  
  (Don't do Lasso - since in the Bayesian setting it doesn't make sense)
  
  - Compare the LOO-PSIS stats for all these models. Which fits the best? 
  
  ```{r}
  library("loo")
  mod3_loo <- loo(extract_log_lik(mod3, "log_lik"))
  mod3_loo
  ```
  
  ```{r}
  mod4_loo <- loo(extract_log_lik(mod4, "log_lik"))
  mod4_loo
  ```
  
  -The LOO-PSIS approximates Leave-one-Out cross validation. LOO-CV estimates the out-of-sample model fit by fitting the model to n−1 observations and predicting the observation that was not included. Given the structure of the data, is this the out-of-sample quantity of interest? Provide another cross-validation example that may be more appropriate and discuss why. You do not need to implement it.
  
  Because of our large sample size, the computational time of LOO is much longer than other cross validation methods that we could use. We could instead use a K-fold cross validation where data are split into K number of groups and the model's predictive ability is tested. K-fold cross validation produces estimates of the prediction error that are less variable. 
  
  -For the best-fitting model, extract the observation level elpd. Plot them across time and
  
  ## Model Size
  
  Compare the model sizes given by loo using the results from the previous section. How does that compare to the actual number of parameters in the model?
  
  The HS prior more aggressively shrinks coefficients towards zero. Is the mean of any coefficient exactly zero? Can you think of a method to define a thresh-hold where coefficients of some variables could be treated as effectively zero? The solutions will provide some examples from the literature (and my Bayesian notes have references to some), but try to think it through on your own. The idea isn’t to get it “right”, but think about the problem prior to finding out how others have approached (and maybe solved?) the problem.
  
  ## Posterior Predictive Checks
  
  Thus far, we’ve only compared models using the log-posterior values. Using a statistic of your choice, assess the fit of data generated from the model to the actual data using posterior predictive checks.
  
  ## Taking Time Seriously
  
  Generally the probbility of war onset is a function of time since the last war.
  One variable not in the previous models is the time since the last civil war; though it is discussed in a footnote of @Fearon1998a [fn. 26].
  @BeckKatzTucker1998a note that a duration model with time-varying covariates can be represented as a binary choice model that includes a function of the time at risk of the event.
  As such we could rewrite the model
  $$
  \eta_{c,y} = x_{c,y}'\beta + f(d_{c,y})
  $$
    where $d_{i,t}$ is the time since the last civil war or the first observation of that country in the data.
  
  One issue is that we don't know the duration function, $f$.
  Since $f$ is unkown, and the analyst generally has few priors about it, generally a flexible funcitonal form is used. @BeckKatzTucker1998a suggest using a cubic spline, while @CarterSignorino2010a suggest a polynomial.
  In particular, @CarterSignorino2010a suggest a cubic polynomial, meaning the linear predictors now becomes,
  $$
  \eta_{c,y} = x_{c,y}'\beta + \gamma_1 d_{c,y} + \gamma_2 d_{c,y}^2 + \gamma_3 d_{c,y}^3
$$

- @CarterSignorino2010 argue that a cubic polynomial is usually sufficient to capture the time-dependence in this sort of data. This is another sort of model choice. How would you solve the choice of the the order of the polynomial with regularization? Include this variable, and re-estimate a model.

```{r}
mod5<-stan_glm(onset ~ warl + warl^2 + warl^3, family = binomial(), data = df, prior = normal(0,1))
mod5
```

## Time Trends and Time-Varying Coefficients