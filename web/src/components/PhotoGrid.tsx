import { Text } from "@mantine/core";
import { IconPaw } from "@tabler/icons-react";
import { AppColors } from "../theme/constants";
import { type AnimalImageResponse } from "../features/animals/animalsRepository";
import { LAYOUT_CONSTANTS } from "../features/animals/constants";

interface PhotoGridProps {
  images: AnimalImageResponse[];
  name: string;
  onImageClick: (url: string) => void;
}

export default function PhotoGrid({
  images,
  name,
  onImageClick,
}: PhotoGridProps) {
  const sorted = [...images]
    .sort((a, b) => a.order - b.order)
    .slice(0, LAYOUT_CONSTANTS.PHOTO_GRID_MAX_IMAGES);

  const count = sorted.length;

  if (count === 0) {
    return (
      <div
        style={{
          height: LAYOUT_CONSTANTS.PHOTO_GRID_EMPTY_HEIGHT,
          background: AppColors.tintedBg,
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          flexDirection: "column",
          gap: LAYOUT_CONSTANTS.PHOTO_GRID_GAP,
        }}
      >
        <IconPaw size={48} color={AppColors.outline} stroke={1.2} />
        <Text c="dimmed" size="sm">
          No photos yet
        </Text>
      </div>
    );
  }

  return (
    <div style={{ background: AppColors.tintedBg, padding: "24px 0 0 0" }}>
      <div
        style={{
          display: "flex",
          justifyContent: "center",
          gap: LAYOUT_CONSTANTS.PHOTO_GRID_GAP,
          padding: "0 16px",
          maxWidth: LAYOUT_CONSTANTS.PHOTO_GRID_MAX_WIDTH,
          margin: "0 auto",
        }}
      >
        {sorted.map((img) => {
          const flexBasis = `calc(${100 / count}% - ${(LAYOUT_CONSTANTS.PHOTO_GRID_GAP * (count - 1)) / count}px)`;

          return (
            <div
              key={img.id}
              onClick={() => onImageClick(img.url)}
              style={{
                flex: `0 0 ${flexBasis}`,
                maxWidth: LAYOUT_CONSTANTS.PHOTO_GRID_ITEM_MAX_WIDTH,
                borderRadius: LAYOUT_CONSTANTS.CARD_RADIUS,
                overflow: "hidden",
                border: `1px solid ${AppColors.divider}`,
                aspectRatio: "3 / 3",
                cursor: "pointer",
              }}
              className="group"
            >
              <img
                src={img.url}
                alt={name}
                className="transition-transform duration-300 ease-out group-hover:scale-105" //zoom
                style={{
                  width: "100%",
                  height: "100%",
                  objectFit: "cover",
                  objectPosition: "center",
                  display: "block",
                }}
              />
            </div>
          );
        })}
      </div>
    </div>
  );
}
