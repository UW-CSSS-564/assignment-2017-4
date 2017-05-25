data {
  // number of observations
  int N;
  // response vector
  vector[N] ons;
  // number of columns in the design matrix X
  int K;
  // design matrix X
  matrix [N, K] X;
  // duration ^ 1
  vector[N] d_i;
  // duration ^ 2
  vector[N] d_ii;
  // duration ^ 3
  vector[N] d_iii;
}
parameters {
  // regression coefficient vector
  real a;
  real y_i;
  real y_ii;
  real y_iii;
  vector[K] b_raw;
  // scale of the regression errors
  real<lower = 0.> sigma;
  // global scale for coefficients
  real<lower = 0.> tau;
  // local scales of coefficients
  vector<lower = 0.>[K] lambda;
}
transformed parameters {
  // mu is the observation fitted/predicted value
  // also called yhat
  vector[N] mu;
  vector[K] b;
  b = b_raw * tau .* lambda;
  mu = X * b + y_i * d_i + y_ii * d_ii + y_iii * d_iii;
}
model {
  // priors
  lambda ~ student_t(3, 0., 1.);
  a ~ normal(0., 10);
  b_raw ~ normal(0., 2.5);
  tau ~ student_t(3, 0., 1.);
  sigma ~ cauchy(0., 1.);
  // priors for the polynomial
  y_i ~ student_t(3, 0, 1);
  y_ii ~ student_t(3, 0, 1);
  y_iii ~ student_t(3, 0, 1);
  // likelihood
  ons ~ normal(mu, sigma);
}
 generated quantities {
  // simulate data from the posterior
  vector[N] y_rep;
  // log-likelihood posterior
  vector[N] log_lik;
  for (n in 1:N) {
    y_rep[n] = normal_rng(mu[n], sigma);
    log_lik[n] = normal_lpdf(ons[n] | mu[n], sigma);
  }
}
