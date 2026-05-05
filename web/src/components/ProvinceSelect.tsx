import { useEffect, useState } from "react";
import { Select, type SelectProps, Loader } from "@mantine/core";
import { IconMapPin } from "@tabler/icons-react";
import {
  geoRepository,
  type Province,
} from "../features/locations/locationRepository";
import { AppColors } from "../theme/constants";

interface ProvinceSelectProps extends Omit<SelectProps, "data"> {}

export default function ProvinceSelect(props: ProvinceSelectProps) {
  const [provinces, setProvinces] = useState<Province[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    geoRepository
      .getProvinces()
      .then((res) => setProvinces(res ? res.provinces : []))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const provinceOptions = provinces.map((p) => ({
    value: p.id,
    label: p.name,
  }));

  return (
    <Select
      data={provinceOptions}
      searchable
      disabled={loading || props.disabled}
      leftSection={
        loading ? (
          <Loader size="xs" color="primary" />
        ) : (
          <IconMapPin
            size={props.size === "sm" ? 14 : 16}
            color={AppColors.textHint}
          />
        )
      }
      {...props}
    />
  );
}
