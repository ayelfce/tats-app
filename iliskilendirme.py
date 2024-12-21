import os
from itertools import combinations
from collections import Counter
import pandas as pd

labels_folder_path = "./labels/"  
label_files = os.listdir(labels_folder_path)

tepsi_data = {}
for label_file in label_files:
    label_path = os.path.join(labels_folder_path, label_file)
    with open(label_path, 'r') as file:
        ids = [line.split()[0] for line in file.readlines()]
        tepsi_data[label_file] = ids

excel_path = "./foodInfoTable.xlsx"  
sheet_data = pd.read_excel(excel_path)

id_to_name = dict(zip(sheet_data['ID'], sheet_data['Yemek İsmi']))

excluded_items = ['Ekmek', 'Su']
excluded_ids = [str(food_id) for food_id in sheet_data[sheet_data['Yemek İsmi'].isin(excluded_items)]['ID'].tolist()]

tepsi_with_names = {
    tepsi: [id_to_name.get(int(food_id), f"ID_{food_id}") for food_id in food_ids if food_id not in excluded_ids]
    for tepsi, food_ids in tepsi_data.items()
}

all_items = []  
all_combinations = {2: [], 3: [], 4: []} 

for food_names in tepsi_with_names.values():
    unique_foods = set(food_names)
    all_items.extend(unique_foods)  
    for r in range(2, 5):  
        all_combinations[r].extend(combinations(unique_foods, r))


item_counts = Counter(all_items)

combination_counts = {r: Counter(all_combinations[r]) for r in all_combinations}

total_tepsiler = len(tepsi_with_names)   

min_support = 0.001 
min_confidence = 0.3  

def calculate_support_and_confidence(comb_count, item_count, total_tepsiler):
    """Destek ve güven hesaplama."""
    results = []
    for comb, count in comb_count.items():
        support = count / total_tepsiler
        if len(comb) > 1 and item_count.get(comb[0], 0) > 0:  
            confidence = count / item_count[comb[0]]
        else:
            confidence = None

        if support >= min_support and (confidence is None or confidence >= min_confidence):
            results.append((comb, count, support, confidence))
    return sorted(results, key=lambda x: x[1], reverse=True)  
          

single_support_confidence = calculate_support_and_confidence(item_counts, item_counts, total_tepsiler)

comb_support_confidence = {
    r: calculate_support_and_confidence(combination_counts[r], item_counts, total_tepsiler)
    for r in combination_counts
}

def print_results(title, results):
    print(title)
    if results:
        for comb, count, support, confidence in results[:1]:  
            comb_names = ", ".join(comb) if isinstance(comb, tuple) else comb
            print(f"Yemekler: {comb_names}, Adet: {count}, Destek: {support:.2f}, Güven: {confidence if confidence else 'Hesaplanamadı'}")
    else:
        print("Sonuç bulunamadı.")
    print()

print_results("En fazla tüketilen tekli ürün:", single_support_confidence)
print_results("En fazla birlikte tüketilen ikili ürün:", comb_support_confidence[2])
print_results("En fazla birlikte tüketilen üçlü ürün:", comb_support_confidence[3])
print_results("En fazla birlikte tüketilen dörtlü ürün:", comb_support_confidence[4])



