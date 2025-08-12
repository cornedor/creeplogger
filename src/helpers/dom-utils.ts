export function getMultiSelectValues(id: string): string[] {
  const el = document.getElementById(id) as HTMLSelectElement | null;
  if (!el) return [];
  return Array.from(el.selectedOptions).map(o => o.value);
}