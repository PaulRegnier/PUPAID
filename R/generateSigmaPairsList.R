#' Generate a list of different sigma pairs to benchmark
#'
#' This function generates a list of different sigma pairs to benchmark. The function uses the `radius` argument to estimate the base `sigmaLow` value to use (using the `radius = (sigma * (sqrt(2*log(255, 2)))) - 1 relation)`, then generates different `sigmaHigh` values by multiplying `sigmaLow` with different multiplicators specified by the `maxSigmaRatio` and the `step` arguments. For instance, a `maxSigmaRatio` argument set to `2` and a `step` argument set to `0.25` will generate the following multiplicators: `c(1.25, 1.5, 1.75, 2)` which will be multiplied by the computed `sigmaLow` value, thus leading to 4 different sigma pairs to test.
#'
#' @param radius The estimated overall cell radius mean (in µm). This value should be measured under ImageJ.
#'
#' @param maxSigmaRatio The maximum possible value of the `sigmaHigh/sigmaLow` ratio.
#'
#' @param step The step to use to compute the sequence between 1 (excluded) and the `maxSigmaRatio` argument.
#'
#' @export

generateSigmaPairsList = function(radius = NULL, maxSigmaRatio = NULL, step = 0.1)
{
  # If radius = (sigma * (sqrt(2*log(255, 2)))) - 1
  # Then sigma =  round((radius + 1) / (sqrt(2*log(255, 2))), 2)
  a = NULL

  sigma = round((radius + 1) / (sqrt(2*log(255, 2))), 2)


  sigmaPairsSeq = list()
  sigmaRatios = seq(1, maxSigmaRatio, step)[-1]
  foreach::foreach(a = 1:length(sigmaRatios)) %do%
    {

      sigmaPairsSeq[[a]] = c(sigma, sigma*sigmaRatios[a])
    }

}
