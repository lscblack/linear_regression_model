from fastapi import FastAPI, HTTPException
import pandas as pd
import joblib
import numpy as np
from pydantic import BaseModel, Field, validator
from sklearn.preprocessing import LabelEncoder
import uvicorn

# Load the trained model and scaler
best_model = joblib.load('Random Forest_best_model.pkl')
scaler = joblib.load('standard_scaler.pkl')

# Initialize LabelEncoders
sex_encoder = LabelEncoder()
sex_encoder.fit(["male", "female"])

smoker_encoder = LabelEncoder()
smoker_encoder.fit(["yes", "no"])

region_encoder = LabelEncoder()
region_encoder.fit(["southwest", "southeast", "northwest", "northeast"])

app = FastAPI(
    title="Insurance Charges Prediction API",
    description="An API to predict insurance charges based on customer demographics.",
    version="1.0.0"
)

# Request model with validation
class InputData(BaseModel):
    age: int = Field(..., description="Age of the primary beneficiary (in years).", gt=0)
    sex: str = Field(..., description="Gender of the primary beneficiary ('male' or 'female').")
    bmi: float = Field(..., description="Body Mass Index (BMI) of the primary beneficiary.", gt=0)
    children: int = Field(..., description="Number of children/dependents covered by the insurance.", ge=0)
    smoker: str = Field(..., description="Smoking status of the primary beneficiary ('yes' or 'no').")
    region: str = Field(..., description="Region where the primary beneficiary resides ('southwest', 'southeast', 'northwest', 'northeast').")

    # Validate sex
    @validator('sex')
    def validate_sex(cls, value):
        if value not in ["male", "female"]:
            raise ValueError("sex must be either 'male' or 'female'")
        return value

    # Validate smoker
    @validator('smoker')
    def validate_smoker(cls, value):
        if value not in ["yes", "no"]:
            raise ValueError("smoker must be either 'yes' or 'no'")
        return value

    # Validate region
    @validator('region')
    def validate_region(cls, value):
        if value not in ["southwest", "southeast", "northwest", "northeast"]:
            raise ValueError("region must be one of: 'southwest', 'southeast', 'northwest', 'northeast'")
        return value

@app.post(
    "/predict",
    response_model=dict,
    description="""
    Predict insurance charges based on customer demographics.

    **Parameters:**
    - **age**: Age of the primary beneficiary (in years). Must be a positive integer.
    - **sex**: Gender of the primary beneficiary. Must be either 'male' or 'female'.
    - **bmi**: Body Mass Index (BMI) of the primary beneficiary. Must be a positive float.
    - **children**: Number of children/dependents covered by the insurance. Must be a non-negative integer.
    - **smoker**: Smoking status of the primary beneficiary. Must be either 'yes' or 'no'.
    - **region**: Region where the primary beneficiary resides. Must be one of: 'southwest', 'southeast', 'northwest', 'northeast'.

    **Example Input:**
    ```json
    {
      "age": 25,
      "sex": "male",
      "bmi": 28.5,
      "children": 0,
      "smoker": "no",
      "region": "southeast"
    }
    ```

    **Example Output:**
    ```json
    {
      "predicted_charges": 2286.67
    }
    ```

    **Notes:**
    - Ensure all input values are in the correct format to avoid model errors.
    - The model predicts insurance charges based on the provided input features.
    """
)
def predict_charges(data: InputData):
    """
    Predicts insurance charges based on customer demographics.
    """
    try:
        # Convert input data to DataFrame
        df_new = pd.DataFrame([data.dict()])

        # Encode categorical variables
        df_new['sex'] = sex_encoder.transform([data.sex])
        df_new['smoker'] = smoker_encoder.transform([data.smoker])
        df_new['region'] = region_encoder.transform([data.region])

        # Ensure column order
        feature_names = ['age', 'sex', 'bmi', 'children', 'smoker', 'region']
        df_new = df_new[feature_names]

        # Standardize features
        X_new_scaled = scaler.transform(df_new)
        X_new_scaled_df = pd.DataFrame(X_new_scaled, columns=feature_names)

        # Predict
        prediction = best_model.predict(X_new_scaled_df)
        return {"predicted_charges": round(float(prediction[0]), 2)}
    
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# if __name__ == "__main__":
#     uvicorn.run("prediction:app", host="0.0.0.0", port=8000, reload=True)