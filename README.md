## CatastropheBond_MonteCarlo
Pricing a Tornado Catastrophe Bond with Monte Carlo Method


Catastrophe bonds or CAT bonds are an important financial tool in the insurance industry. They provide reinsurers with a means of raising the capital to cover expected losses associated with potential catastrophic events. In this project, team used Monte Carlo simulation techniques on R to price a CAT bond triggered by a tornado hitting the city of Moore, Oklahoma.

### Raw Data
Tornado data: obtained from National Oceanic and Atmospheric Administration (NOAA) Storm Prediction WCM page
Exposure data: obtained from Cleveland Country Assessors office in coop with Moore GIS Department

![image](https://user-images.githubusercontent.com/20606137/27980267-5f7c89fc-6342-11e7-8f0c-8f76dcdb74ff.png)
![image](https://user-images.githubusercontent.com/20606137/27980278-80f33464-6342-11e7-9046-0ac5715eb263.png)


### Assumptions
1. Only one intense tornado can hit the city per year
2. Once the tornado touches down, it will follow a strictly linear path with no jumps and of uniform width. 
3. The probability of occurrence of an intense tornado was uniformly distributed throughout the state.
4. Tornados travel from west to east, or that the x-coordinate of the starting point is less than the x-coordinate of the ending point. 

### Methodology
The general idea is to simulate tornado damage by mapping a pseudo-random, tornado paths on the exposure plane. Any point lying within the path of the tornado will be considered a total loss, and the value of that point will be included in the sum of the loss for that event. 
We can determine the “fair value” of the loss as

![image](https://user-images.githubusercontent.com/20606137/27980370-95ee2ad0-6343-11e7-8269-b258c3cfa310.png)
Where Xi≔{ith individual loss due to tornado} and Li≔{∑Xi |tornado occurs}. 

To get the time zero price of the CAT bond, we employ the discounted cash flow technique using the risk free rate of interest.

![image](https://user-images.githubusercontent.com/20606137/27980404-ee6c9b24-6343-11e7-9597-6adfc68db992.png)

### Implementation
![image](https://user-images.githubusercontent.com/20606137/27980418-130dd5b0-6344-11e7-8b7d-a3a20efab640.png)

### Acknowledgement
This project was jointly done during graduate study at DePaul University with Matthew Glascock & 
I'd like to Thank to Matthew for ideas and methdology development
