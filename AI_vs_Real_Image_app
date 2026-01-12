import streamlit as st
import torch
from transformers import AutoModelForImageClassification, AutoImageProcessor, AutoFeatureExtractor
from PIL import Image
import traceback

# Configuration
MODEL_ID = "Okohogbole/ai-vs-real-resnet50"  # update if needed
DEVICE = torch.device("cpu")

st.set_page_config(page_title="AI vs Real Image Detector", layout="centered")


@st.cache_resource(show_spinner=False)
def load_model():
    """
    Load model + processor with fallbacks:
    - Try AutoImageProcessor
    - Then AutoFeatureExtractor
    - If neither exist, return model and None and we'll do manual preprocessing.
    """
    try:
        model = AutoModelForImageClassification.from_pretrained(MODEL_ID)
    except Exception as e:
        raise RuntimeError(f"Failed to load model from Hugging Face: {e}")

    processor = None
    # Try AutoImageProcessor then AutoFeatureExtractor
    try:
        processor = AutoImageProcessor.from_pretrained(MODEL_ID)
    except Exception:
        try:
            processor = AutoFeatureExtractor.from_pretrained(MODEL_ID)
        except Exception:
            processor = None  # we'll use torchvision transforms as fallback

    model.to(DEVICE)
    model.eval()
    return model, processor


model, processor = None, None
try:
    model, processor = load_model()
except Exception as e:
    st.error("Model failed to load. See logs for details.")
    st.text(traceback.format_exc())

st.title("AI vs Real Image Detector")
st.markdown("Upload an image to check whether it is **AI-generated** or **real**.")

uploaded_file = st.file_uploader("Upload an image (JPG, JPEG, PNG)", type=["jpg", "jpeg", "png"])

def manual_preprocess_pil(image: Image.Image, size=224):
    """
    Minimal preprocessing if HF processor isn't available.
    This matches standard ResNet-style preprocessing:
    - Resize shorter side, center crop, convert to tensor, normalize
    """
    from torchvision import transforms
    transform = transforms.Compose([
        transforms.Resize(size),
        transforms.CenterCrop(size),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406],
                             std=[0.229, 0.224, 0.225]),
    ])
    tensor = transform(image).unsqueeze(0)  # batch dim
    return tensor

label_map = {0: "Real Image", 1: "AI-Generated Image"}  # adjust if model uses different mapping

if uploaded_file is not None:
    try:
        image = Image.open(uploaded_file).convert("RGB")
        st.image(image, caption="Uploaded Image", use_container_width=True)

        if model is None:
            st.error("Model is not available. Please check deployment logs.")
        else:
            with st.spinner("Analyzing image..."):
                # Prepare inputs depending on available processor
                if processor is not None:
                    inputs = processor(images=image, return_tensors="pt")
                    inputs = {k: v.to(DEVICE) for k, v in inputs.items()}
                else:
                    # manual fallback: create pixel_values tensor
                    inputs = {"pixel_values": manual_preprocess_pil(image).to(DEVICE)}

                with torch.no_grad():
                    outputs = model(**inputs)
                    logits = outputs.logits
                    probs = torch.softmax(logits, dim=-1)
                    pred = torch.argmax(probs, dim=-1).item()

                # model may use different label ids — if so, adjust label_map
                confidence = probs[0][pred].item() * 100
                st.success(f"**Prediction:** {label_map.get(pred, str(pred))}  \n**Confidence:** {confidence:.2f}%")

    except Exception as e:
        st.error("Unable to process the image. See logs for details.")
        st.exception(e)
