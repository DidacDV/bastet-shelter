import { Modal } from "@mantine/core";

interface ImageViewerModalProps {
  imageUrl: string | null;
  onClose: () => void;
}

export default function ImageViewerModal({
  imageUrl,
  onClose,
}: ImageViewerModalProps) {
  return (
    <Modal
      opened={!!imageUrl}
      onClose={onClose}
      withCloseButton={false}
      size="auto"
      centered
      overlayProps={{ backgroundOpacity: 0.85, blur: 4 }}
      styles={{
        body: { padding: 0, backgroundColor: "transparent" },
        content: { backgroundColor: "transparent", boxShadow: "none" },
      }}
    >
      {imageUrl && (
        <div style={{ position: "relative" }}>
          <img
            src={imageUrl}
            alt="Expanded view"
            style={{
              maxWidth: "90vw",
              maxHeight: "85vh",
              borderRadius: 12,
              objectFit: "contain",
              display: "block",
              boxShadow: "0 12px 48px rgba(0,0,0,0.3)",
            }}
          />
        </div>
      )}
    </Modal>
  );
}
