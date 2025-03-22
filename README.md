# Medical Insurance Cost Estimator

## Overview
This mobile application provides an automated system to estimate annual medical expenditure for new insurance customers based on demographic and health factors. Using a machine learning model trained on verified historical data from over 1,300 customers, the application predicts insurance premium charges based on age, sex, BMI, number of children, smoking habits, and region of residence.
**Problem Statement**  

Accurately predicting medical insurance costs is crucial for insurance companies to assess risk, set fair pricing, and optimize financial planning. Various factors, such as age, BMI, smoking status, and region, significantly influence healthcare expenses. However, understanding the impact of these factors on insurance charges remains a challenge.  

This project aims to develop a machine learning model that predicts medical expenses based on key demographic and health-related variables. By leveraging predictive analytics, insurance providers can gain deeper insights into cost drivers, refine their pricing strategies, and make data-driven decisions to minimize financial risks. Additionally, this model can help customers estimate their potential medical costs, enabling better financial planning for healthcare expenses.  

---

### **Dataset Overview**  
The dataset consists of **2,700 records** with **7 features** related to medical insurance charges. The key variables include:  

- **Age**: The age of the insured individual (in years).  
- **Sex**: The gender of the insured (male/female).  
- **BMI (Body Mass Index)**: A numerical value indicating body weight relative to height, used to assess obesity levels.  
- **Children**: The number of dependent children covered under the insurance plan.  
- **Smoker**: A categorical variable indicating whether the individual is a smoker (yes/no).  
- **Region**: The geographical region where the individual resides (e.g., northeast, northwest, southeast, southwest).  
- **Charges**: The total medical insurance cost incurred by the individual.  

### **Significance of the Study**  
Understanding how different factors influence medical expenses is critical for insurers to develop fair and competitive pricing models. Smoking status and BMI, for example, are known to be strong predictors of higher healthcare costs. This analysis will:  

1. Identify key factors driving insurance costs.  
2. Improve the accuracy of medical expense predictions.  
3. Enable insurance companies to optimize pricing strategies.  
4. Help individuals estimate future medical costs based on their personal attributes.  

By building a robust predictive model, we aim to enhance transparency in insurance pricing and contribute to more data-driven decision-making in the healthcare insurance industry.
![Insurance Estimator App](https://via.placeholder.com/600x300)

## Project Structure
```
linear_regression_model/
│
├── summative/
│   ├── linear_regression/
│   │   ├── multivariate.ipynb
│   │
│   ├── API/
│   │   ├── prediction.py
│   │   ├── requirements.txt
│   │
│   ├── FlutterApp/
│       └── [Flutter app files]
```

## Features
- Predict insurance costs based on customer information
- User-friendly mobile interface
- Secure connection to prediction API
- Real-time cost estimation

## Machine Learning Model
After evaluating multiple models including Linear Regression with Gradient Descent, Decision Tree, and Random Forest, the **Random Forest Regressor** was selected as the best performing model based on the following metrics:

```
Model Performance Summary:
                    Model  Train R2   Test R2     Train MSE      Test MSE
0  Linear Regression (GD)  0.741469  0.784460  3.731472e+07  3.346224e+07
1           Decision Tree  0.914874  0.830618  1.228653e+07  2.629635e+07
2           Random Forest  0.910396  0.877983  1.293286e+07  1.894296e+07
```

The Random Forest model was chosen because it:
- Provides the highest test R² score (0.878)
- Has the lowest test MSE (Mean Squared Error) of 18.94 million
- Offers better generalization than Decision Trees while maintaining comparable training performance
- Has good resistance to overfitting while capturing non-linear relationships in the data

The model uses the following features to predict insurance costs:
- **age**: Age of the insurance policyholder
- **sex**: Gender of the insurance policyholder
- **bmi**: Body Mass Index (BMI) of the insurance policyholder
- **children**: Number of children covered under the insurance policy
- **smoker**: Indicates whether the policyholder is a smoker (Yes/No)
- **region**: Geographical region of the policyholder ('southwest', 'southeast', 'northwest', 'northeast')

## API Service

The prediction API is built with FastAPI and is deployed on Render.

### API Endpoint
- **URL**: [https://linear-regression-model-oy9v.onrender.com/](https://linear-regression-model-oy9v.onrender.com/)
- **Swagger UI**: [https://linear-regression-model-oy9v.onrender.com/docs](https://linear-regression-model-oy9v.onrender.com/docs)

### API Usage
You can make predictions by sending a POST request to the `/predict` endpoint with the following JSON format:

```json
{
  "age": 35,
  "sex": "male",
  "bmi": 25.7,
  "children": 2,
  "smoker": "no",
  "region": "southwest"
}
```

Example response:
```json
{
  "predicted_charge": 8956.78
}
```

## Mobile Application Setup

### Prerequisites
- Flutter SDK (2.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Android or iOS device or emulator

### Installation Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/lscblack/linear_regression_model.git
   cd linear_regression_model/summative/FlutterApp
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Using the App
1. Enter the required information: age, sex, BMI, number of children, smoking status, and region
2. Press "Calculate Estimate" button
3. View the estimated annual insurance cost

## Testing

### Testing the Machine Learning Model
1. Navigate to the Jupyter notebook:
   ```bash
   cd linear_regression_model/summative/linear_regression
   jupyter notebook multivariate.ipynb
   ```
2. Run all cells to train and evaluate the model

### Testing the API
1. Access the Swagger UI at [https://linear-regression-model-oy9v.onrender.com/docs](https://linear-regression-model-oy9v.onrender.com/docs)
2. Use the `/predict` endpoint with sample data
3. Alternatively, use curl:
   ```bash
   curl -X POST "https://linear-regression-model-oy9v.onrender.com/predict" -H "Content-Type: application/json" -d '{"age": 30, "sex": "female", "bmi": 28.5, "children": 1, "smoker": "no", "region": "northeast"}'
   ```

### Testing the Flutter App
1. Run the app on an emulator or physical device
2. Enter test data and verify the results match expectations
3. Check edge cases (e.g., extreme ages, BMI values)

## Demo

[![Insurance Estimator Demo](https://img.youtube.com/vi/YOUR_VIDEO_ID/0.jpg)](https://www.youtube.com/watch?v=YOUR_VIDEO_ID)

[Watch Demo Video (2 minutes)](https://www.youtube.com/watch?v=YOUR_VIDEO_ID)

## Resources
- [GitHub Repository](https://github.com/lscblack/linear_regression_model)
- [API Documentation](https://linear-regression-model-oy9v.onrender.com/docs)

## License
MIT License

## Contact
For questions or support, please open an issue on the [Email](l.christian@alustudent.com).

## Author
Loue Sauveur Christian (lscblack), <l.christian@alustudent.com>