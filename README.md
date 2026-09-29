# PackSense

PackSense is an **AI/ML-based Food Packaging Recommendation System**. It matches food commodities and product specifications with optimal, sustainable barrier packaging materials.

## Overview

PackSense helps food producers, commercial kitchens, and packaging engineers determine suitable food packaging materials based on:
- **Food Characteristics:** Commodity profiles, physical states, moisture levels, pH/acidity, fat/oil content.
- **Storage & Shelf Life:** Storage temperatures (room temp, refrigerated, frozen) and target freshness duration.
- **Logistics & Fragility:** Transport distance and impact protection.
- **Economic & Environmental Goals:** Recyclability, compostability, and budget optimization.

## Technology Stack

- **Frontend:** Flutter / Dart 
- **UI/UX Source of Truth:** Google Stitch Design Specifications (Plus Jakarta Sans, Epistemic status cues, 52px safe touch targets)
- **Backend (Future):** FastAPI
- **ML Engine (Future):** Python + Scikit-learn
- **Database & Auth:** Supabase

## Project Structure

```
PackSense/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── theme/          # AppColors, AppTypography, AppTheme
│   │   └── widgets/        # Reusable buttons, cards, progress bars, tags
│   ├── data/
│   │   ├── models/         # FoodItem, FoodProperties, PackagingMaterial, Recommendation
│   │   └── repositories/   # PackagingRepository
│   └── presentation/
│       ├── home/           # Home screen & components
│       ├── materials/      # Materials catalog & technical specifications
│       └── recommendation_flow/ # 4-step recommendation flow
├── pubspec.yaml
├── .gitignore
└── stitch_packsense_ui_ux_design/ # Stitch UI reference design assets
```

## Getting Started

1. Ensure Flutter SDK (>= 3.0.0) is installed.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```
