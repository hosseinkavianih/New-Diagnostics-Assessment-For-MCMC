NSAMPLES=1000
METHOD=Latin
JAVA_ARGS="Bayesian/Hyperparameters/MOEAFramework-2.13-Demo.jar"

# Generate the parameter samples
echo -n "Generating parameter samples..."
java ${JAVA_ARGS} \
    org.moeaframework.analysis.sensitivity.SampleGenerator \
    --method ${METHOD} --n ${NSAMPLES} --p MH_Param2.txt \
    --o MH_sample3.txt
