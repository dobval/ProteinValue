enum Rankings {
  cheapProteinRich(
    displayName: 'Cheap Protein-Rich',
    explanation:
        'Calculated as Protein/Price. Example: (11*5)/1,49 = 36,92g for 1€ (ja! Skyr Natur 500g 1,49€; 11g Protein per 100g).',
    formula: 'Protein/Price',
  ),
  leanProteinRich(
    displayName: 'Lean Protein-Rich',
    explanation: 'Calculated as Protein/Kcal. Example: Chicken Breast',
    formula: 'Protein/Kcal',
  ),
  cheapLeanProteinRich(
    displayName: 'Cheap Lean Protein-Rich',
    explanation: 'Calculated as (Protein/Price)/Kcal. Example: Low-fat Cheese',
    formula: '(Protein/Price)/Kcal',
  ),
  cheapHighCalorie(
    displayName: 'Cheap High-Calorie',
    explanation: 'Calculated as Kcal/Price. Examples: Flour, Oil',
    formula: 'Kcal/Price',
  );

  final String displayName;
  final String explanation;
  final String formula;

  const Rankings({
    required this.displayName,
    required this.explanation,
    required this.formula,
  });
}
