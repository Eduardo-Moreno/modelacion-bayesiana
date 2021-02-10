// Modelo de regresión logística para tiros de golf
functions {
  real prob_ang(real x, real sigma) {
    return 2 * normal_cdf(atan(3.25 / x), 0, sigma) - 1;
  }
  real prob_dist(real x, real sigma, real rho){
    return 2 * normal_cdf(0.82 / ( 0.82 + 3.26 *(rho) * x), 0, sigma) - 1;
  }
}

data {
  // observaciones
  int p; // Número de cubetas
  int x[p]; // Distancia para cubeta
  int n[p]; // Número de intentos en cada cubeta
  int exitos_obs[p]; // Número de exitos en cada cubeta
  real gamma_ang_pars[2];
  real gamma_dist_pars[2];
}

parameters {
  real<lower=0> sigma_ang;
  real<lower=0> sigma_dist;
}

transformed parameters {
  real<lower=0, upper=1> prob_exito[p];
  for(i in 1:p) {
   prob_exito[i] = prob_ang(x[i], sigma_ang) * prob_dist(x[i], sigma_dist, 0.131); 
  }
}

model {
  //iniciales
  sigma_ang ~ gamma(gamma_ang_pars[1], gamma_ang_pars[2]);
  sigma_dist ~ gamma(gamma_dist_pars[1], gamma_dist_pars[2]);
  //observaciones
  for(i in 1:p){
    exitos_obs[i] ~ binomial(n[i], prob_exito[i]);
  }
}

generated quantities {
  real prob_sim[p];
  for(i in 1:p){
    prob_sim[i] = binomial_rng(n[i], prob_exito[i]);
    prob_sim[i] = prob_sim[i] / n[i];
  }
}

