export function formatAge(birthDate: string): string {
  const birth = new Date(birthDate);
  const now = new Date();
  const years = now.getFullYear() - birth.getFullYear();
  const months = now.getMonth() - birth.getMonth();
  const totalMonths = years * 12 + months;

  if (totalMonths < 1) return "Less than a month old";
  if (totalMonths < 12)
    return `${totalMonths} month${totalMonths > 1 ? "s" : ""} old`;
  if (years === 1) return "1 year old";
  return `${years} years old`;
}

export function formatDate(dateStr: string): string {
  return new Date(dateStr).toLocaleDateString("en-GB", {
    day: "numeric",
    month: "long",
    year: "numeric",
  });
}
