NSAMPLES=1000
METHOD=Latin
JAVA_ARGS="-cp /gpfs/gpfs0/project/quinnlab/hk3sku/Scratch-Old/hk3sku/MCMC/Parameters/MOEAFramework-2.13-Demo.jar"

# Generate the parameter samples
echo -n "Generating parameter samples..."
java ${JAVA_ARGS} \
    org.moeaframework.analysis.sensitivity.SampleGenerator \
    --method ${METHOD} --n ${NSAMPLES} --p MH_Param2.txt \
    --o MH_sample3.txt